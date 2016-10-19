Fork: http://www195.pair.com/mik3hall/index.html#trz

This build has been tested with JDK8 (Oracle and Zulu on MacOS Sierra). LotsOfTests passes.

Build:

```
$ mvn clean install -DskipTests
$ cp libmacattrs.dylib /Library/Java/JavaVirtualMachines/jdk8/jre/lib/  (be careful with patching your JDK)
```

Dependency:

```
<dependency>
    <groupId>us.hall.trz.osx</groupId>
    <artifactId>watchservice</artifactId>
    <version>1.0-SNAPSHOT</version>
    <scope>compile</scope>
</dependency>
``` 

Usage:

```
$ java -cp macnio2.jar -Djava.nio.file.spi.DefaultFileSystemProvider=us.hall.trz.osx.MacFileSystemProvider LotsOfEvents

$ java -cp target/watchservice-1.0-SNAPSHOT.jar -Djava.nio.file.spi.DefaultFileSystemProvider=us.hall.trz.osx.MacFileSystemProvider LotsOfEvents
```

```
$ mvn clean test -Djava.nio.file.spi.DefaultFileSystemProvider=us.hall.trz.osx.MacFileSystemProvider -Dtest=MacWatchersTest

$ mvn clean test -Djava.nio.file.spi.DefaultFileSystemProvider=us.hall.trz.osx.MacFileSystemProvider
```



