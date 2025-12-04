# Astrolabe
Inline-style: 
![alt text]([https://github.com/adam-p/markdown-here/raw/master/src/common/images/icon48.png](https://preview.redd.it/can-someone-explain-the-meaning-of-this-art-v0-pqktyu7doo2d1.jpeg?auto=webp&s=315ab2484e91f5c6e76c588c0eed4280f7e1384e) "Logo Title Text 1")
Maritime celestial navigation

## Quickstart

1. Clone the repository:

```bash
git clone https://github.com/bnSaxon/astrolabe.git
cd astrolabe
```

2. Build the docker container using the build script:

```bash
./build.bash
```

3. Run the docker container using the run script:


```bash
./run.bash
```

4. Mount or download index files

Index files are catalogs of stars patterns that the solver algorithm uses. After running run.sh, you will be prompted to provide index files. You can either mount an existing directory or download files ephemerally from inside the container using a provided script.

If you choose to mount it from host, simply provide the directory.

If you do not mount your own index directory, the container includes a helper script:

```bash
download_astrometry_indexes 4100 4200 5200
```

The arguments proceeding it indicate which indexes. They will be placed into /data/index/

5. Solving Images

```bash
solve-field your_image.jpg
```
