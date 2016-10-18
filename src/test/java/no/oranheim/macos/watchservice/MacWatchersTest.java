package no.oranheim.macos.watchservice;

import no.oranheim.macos.watchservice.osx.MacFileSystem;
import no.oranheim.macos.watchservice.osx.MacPath;
import no.oranheim.macos.watchservice.osx.ws.impl.KQueueWatchService;
import org.junit.Test;

import java.io.IOException;
import java.nio.file.*;
import java.util.List;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.fail;

public class MacWatchersTest {
    @Test
    public void testSetup() {
        try {
            FileSystem fs = FileSystems.getDefault();
            assertEquals("correct filesystem class", MacFileSystem.class, fs.getClass());
            Path projidx = fs.getPath(System.getProperty("user.dir"), "doc/index.html");
            Path dir = fs.getPath(System.getProperty("user.dir"), "test");
            assertEquals("correct path class", MacPath.class, dir.getClass());
            System.setProperty("mac.watchservice", "kqueue");
            WatchService ws = null;
            try {
                ws = fs.newWatchService();
            } catch (IOException ioex) {
                fail(ioex.toString());
            }
            assertEquals("correct kqueue watcher class", KQueueWatchService.class, ws.getClass());
            dir.register(ws, StandardWatchEventKinds.ENTRY_CREATE, StandardWatchEventKinds.ENTRY_MODIFY, StandardWatchEventKinds.OVERFLOW, StandardWatchEventKinds.ENTRY_DELETE);
            // Do some file system stuff
            // CREATE
            System.out.println("getting build path");
            Path build = dir.resolve("build.xml");
            System.out.println("getting copy path");
            Path build_copy = dir.resolve("build_copy.xml");
            if (Files.exists(build_copy))
                Files.delete(build_copy);                // Delete if already exists
            System.out.println("copying");
            Files.copy(build, build_copy);
            Thread.sleep(7);
            System.out.println("getting renamed path");
            Path renamed = dir.resolve("build_delete.xml");
            System.out.println("renaming");
            Files.move(build_copy, renamed);
            Thread.sleep(7);
            System.out.println("deleting");
            Files.delete(renamed);
            Thread.sleep(7);
            System.out.println("test html");
            Path testIndex = dir.resolve("doc/index.html");
            System.out.println("test index " + testIndex);
            Files.copy(projidx, testIndex);
            System.out.println("copied index");
            Path renamedIndex = dir.resolve("doc/renamed_index.html");
            Files.move(testIndex, renamedIndex);
            Thread.sleep(7);
            Files.delete(renamedIndex);

            WatchKey k = ws.take();
            System.out.println("watchkey " + k);
            List<WatchEvent<?>> events = k.pollEvents();
            for (WatchEvent<?> event : events)
                System.out.println(event);
        } catch (Throwable tossed) {
            tossed.printStackTrace();
            fail(tossed.toString());
        }
    }
}
