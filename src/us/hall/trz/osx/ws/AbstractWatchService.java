package us.hall.trz.osx.ws;

import java.io.IOException;
import java.nio.file.ClosedWatchServiceException;
import java.nio.file.Path;
import java.nio.file.WatchEvent;
import java.nio.file.WatchKey;
import java.nio.file.WatchService;
import java.util.concurrent.LinkedBlockingDeque;
import java.util.concurrent.TimeUnit;
import us.hall.trz.osx.ws.impl.FSEventWatchService;
import us.hall.trz.osx.ws.impl.KQueueWatchService;

public abstract class AbstractWatchService implements WatchService {

	protected static final int FILE_CREATED       = 0x00000001;
    protected static final int FILE_MODIFIED      = 0x00000002;
//    private static final int FILE_ATTRIB        = 0x00000004;
    protected static final int FILE_DELETED       = 0x00000008;
//    private static final int FILE_NOFOLLOW      = 0x10000000;
    
    // signaled keys waiting to be dequeued
    private final LinkedBlockingDeque<WatchKey> pendingKeys =
        new LinkedBlockingDeque<WatchKey>();
 
    // used when closing watch service
    private volatile boolean closed;
    private final Object closeLock = new Object();

    // special key to indicate that watch service is closed
    private final WatchKey CLOSE_KEY =
        new AbstractWatchKey(null, null) {
            @Override
            public boolean isValid() {
                return true;
            }

            @Override
            public void cancel() {
            }
        };
        
    public static WatchService getImpl() {
		try {
			if (System.getProperty("mac.watchservice","fsevent").equals("kqueue")) return new KQueueWatchService();
			// default
			return new FSEventWatchService();
		}
		catch (IOException ioex) { ioex.printStackTrace(); }
		return null;
	}
	
	abstract public WatchKey register(Path dir,
					  WatchEvent.Kind<?>[] events,
					  WatchEvent.Modifier... modifiers)
		throws IOException;

    /**
     * Throws ClosedWatchServiceException if watch service is closed
     */
    private void checkOpen() {
        if (closed)
            throw new ClosedWatchServiceException();
    }
    
	@Override
	public final WatchKey take()
		throws InterruptedException
	{
        checkOpen();
        WatchKey key = pendingKeys.take();
        checkKey(key);
        return key;
	}
	
    // used by AbstractWatchKey to enqueue key
    final void enqueueKey(WatchKey key) {
        pendingKeys.offer(key);
    }
 
    /**
     * Checks the key isn't the special CLOSE_KEY used to unblock threads when
     * the watch service is closed.
     */
    private void checkKey(WatchKey key) {
        if (key == CLOSE_KEY) {
            // re-queue in case there are other threads blocked in take/poll
            enqueueKey(key);
        }
        checkOpen();
    }

    @Override
    public final WatchKey poll() {
        checkOpen();
        WatchKey key = pendingKeys.poll();
        checkKey(key);
        return key;
    }

    @Override
    public final WatchKey poll(long timeout, TimeUnit unit)
        throws InterruptedException
    {
        checkOpen();
        WatchKey key = pendingKeys.poll(timeout, unit);
        checkKey(key);
        return key;
    }
    
	/**
     * Closes this watch service. This method is invoked by the close
     * method to perform the actual work of closing the watch service.
     */
    protected abstract void implClose() throws IOException;
    
	@Override
	public final void close()
		throws IOException
	{
		synchronized (closeLock) {
			// nothing to do if already closed
	        if (closed)
	        	return;
	        closed = true;

	        implClose();

	        // clear pending keys and queue special key to ensure that any
	        // threads blocked in take/poll wakeup
	        pendingKeys.clear();
	        pendingKeys.offer(CLOSE_KEY);
	    }
	}
}