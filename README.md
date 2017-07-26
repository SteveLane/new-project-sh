# New Project

This repository provides a `bash` script tailored towards my use of `R`/#rstats for data analyses.

It goes towards my frustration of creating directories, `Makefile`'s and assorted other scripts when I start a new project.

Some of the inspiration is from [https://github.com/chendaniely/computational-project-cookie-cutter](https://github.com/chendaniely/computational-project-cookie-cutter).

## Usage

Simply make the script executable `chmod u+x new_project.sh`, and call it with the name of the new project as the argument:

```bash
$ ./new_project.sh target_directory
```

If you want it o be available everyone, copy it over to `/usr/local/bin`.

## What the script does

The script sets up a new project directory in the manner that **I** like (ymmv). The directory structure is as follows:

```bash
├── data
├── data-raw
├── figs
├── Makefile
├── manuscripts
├── R
│   └── ipak.R
├── README.md
└── scripts
    └── strip-libs.sh
```

The `Makefile` is basic. The functions `ipak.R` and `strip-libs.sh` can be used via `make install-packages` (see [http://stevelane.github.io/blog/2017/05/17/awk-packages](http://stevelane.github.io/blog/2017/05/17/awk-packages)).
