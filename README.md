What is This?
-------------
This container is used to encode videos using ffmpeg with the libaom-av1 codec.

How does it work?
-----------------
Steps:
- Goes through each file in the input directory
- Makes sure it does not already exist in the output directory
- Encodes the video using libaom-av1 into a temporary output file
- Renames the temporary file to a permanent file once successful

```
docker build -t encoder .
docker run --rm -v /path/to/input:/i -v /path/to/output:/o encoder
```

### Examples
```
docker run --rm -v D:\vids\obs:/i -v D:\vids\encoded:/o ghcr.io/molnia1311/encoder:latest
```

Why was it made?
----------------
Encoding is a small part of a bigger workflow of mine. The containerization makes it easy to use in a containerized environment like k8s. It's designed to be used in workflows like argo workflows, to process videos in a scalable manner.
