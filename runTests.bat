dub build --force

cd test
dub build --force

cd ../bin
.\beast_testsuite.exe

pause