# 🐳 dockerfiles/

This folder contains everything needed to build the software/tool images used in the `emlexp80` pipeline. Each subfolder corresponds to one specific software/tool and includes:

-   A `Dockerfile` to define the environment
-   A `build.sh` script to build the image

These images are later converted into `.sif` files using Apptainer for execution on SLURM.

---

## 📁 Folder Structure

```
dockerfiles/
├── fastp/
│   ├── Dockerfile
│   └── build.sh
├── metabolic/
│   ├── Dockerfile
│   └── build.sh
├── ...
```

---

## 🚀 How to Build All Images

To build all images and convert them into `.sif` files, run from the root of the repository:

```bash
bash build_sifs.sh
```

This script will:

-   Build each Docker image using the corresponding `Dockerfile`
-   Convert the Docker image into an Apptainer `.sif` image
-   Place the `.sif` images into the `images/` directory

---

## 🔧 How to Build a Single Image Manually

If you only need to build one tool's image:

```bash
cd dockerfiles/<tool_name>
bash build.sh
```

This builds the Docker image but does not convert it to `.sif` — for that, you can run:

```bash
apptainer build ../../images/<tool_name>.sif docker-daemon://emlexp80-<tool_name>:latest
```

---

## 📦 Notes

-   The image names must match those expected by the `submitters/` scripts via the `-i` option to `launcher.sh`.
-   Each image should be self-contained and only include what is required for that specific tool.
-   Versioning, labels, and reproducibility are encouraged (e.g., using `LABEL` fields in Dockerfiles).
