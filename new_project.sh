#!/usr/bin/env bash
# Little script to create a new data analysis project directory
# Requires a single cmdline argument for the new project name
# With inspiration from https://github.com/chendaniely/computational-project-cookie-cutter
# Time-stamp: <2017-07-26 14:29:18 (slane)>

# Don't kill files
set -o noclobber

# Exit if no arguments were provided.
[ $# -eq 0 ] && { echo "Usage: $0 [target directory]"; exit 1; }

# Create the base project directory
mkdir $1

# Create the extra required directories
cd $1
mkdir data data-raw figs manuscripts R scripts

# Add a README.md
cat > README.md <<EOF
# Project name

## Project description

Add some description here.
EOF

# Add a basic .gitignore
cat > .gitignore <<EOF
# Git ignore file
*.pdf
*.png
*.doc
*.docx
*.xls
*.xlsx
*.aux
*.log
*.lot
*.ttt
*.out
*.bbl
*.Rhistory
*.html
*.RData
*.rds
*.rda
*.tex
*.fdb_latexmk
*.fls
*.toc
*.lof
*.fff
*.blg
*.bcf
*.rec
*.run.xml
*.zip
*.txt
*~
manuscripts/cache/*
manuscripts/auto/*
.DS_Store
EOF

# Add a basic Makefile
cat > Makefile <<EOF
# Makefile
# Time-stamp: <>
.PHONY: all install-packages clean-manuscripts clobber

all: install-packages data/data.rds manuscripts/manuscript.pdf

################################################################################
# Rules to make data
# data/data.rds: R/clean-data.R data-raw/data.csv
# 	cd \$(<D); \\
# 	Rscript --no-save --no-restore \$(<F)

################################################################################
# Rules to make manuscripts
# manuscripts/manuscript.tex: manuscripts/manuscript.Rnw data/data.rds
# 	cd \$(<D); \\
# 	Rscript --no-save --no-restore \$(<F)

# manuscripts/manuscript.pdf: manuscripts/manuscript.tex
# 	cd \$(<D); \\
# 	latexmk -pdf \$(<F)

# manuscripts/manuscript.html: manuscripts/manuscript.Rmd
# 	cd \$(<D); \\
# 	Rscript --no-save --no-restore -e "rmarkdown::render('\$(<F)')"

################################################################################
# Cleaning up
clean-manuscripts:
	cd manuscripts/; \\
	rm -f *.aux *.bbl *.bcf *.blg *.fdb_latexmk *.fls *.lof *.log *.lot \\
		*.code *.loe *.toc *.rec *.out *.run.xml *~ *.tex

clobber: clean-manuscripts
	cd manuscripts/; \\
	rm -rf auto/ cache/ figure/

################################################################################
# Rule to install packages (from script extraction).
# This has been provided for the case where library/require calls are made in
# separate scripts. If the packages are not installed, make should return an
# error, saying that the packages are not available. This is politic; don't
# assume the user wants to install stuff without asking.
install-packages: scripts/strip-libs.sh R/ipak.R
	cd scripts; \\
	chmod u+x strip-libs.sh; \\
	./strip-libs.sh ../scripts/ installs.txt; \\
	Rscript --no-save --no-restore ../R/ipak.R insts=installs.txt
EOF

# Add install packages scripts
cat > scripts/strip-libs.sh <<EOF
#!/usr/bin/env bash
# Strips libraries from .R/.r scripts and creates a text file with a list of them.
# Requires first argument as folder where scripts are stored, and second as the
# text file it is stored in.
folder=\$1
inst=\$2
if [ -f \$inst ] ; then
    rm \$inst
fi
for filename in \$folder/*.R; do
    if [ -f \$filename ]; then
	awk -F '[(]|[)]' '/^library|^require/{print \$2;}' \$filename >> \$inst
    fi
done
for filename in \$folder/*.r; do
    if [ -f \$filename ]; then
	awk -F '[(]|[)]' '/^library|^require/{print \$2;}' \$filename >> \$inst
    fi
done
sort < \$inst > \$inst.bk
uniq < \$inst.bk > \$inst
rm \$inst.bk
EOF

cat > R/ipak.R <<EOF
#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly = TRUE)
################################################################################
################################################################################
## Title: ipak
## Author: Steve Lane
## Synopsis: Script to test for installed packages, and if not installed,
## install them.
## Time-stamp: <>
################################################################################
################################################################################
if(!(length(args) == 1)){
    stop("A single argument must be passed to ipak.R: insts.\ninsts is the location of a newline separated list of required packages.\nExample: Rscript ipak.R insts=../installs.txt",
         call. = FALSE)
} else {
    hasOpt <- grepl("=", args)
    argLocal <- strsplit(args[hasOpt], "=")
    for(i in seq_along(argLocal)){
        value <- NA
        tryCatch(value <- as.double(argLocal[[i]][2]), warning = function(e){})
        if(!is.na(value)){
            ## Assume int/double
            assign(argLocal[[i]][1], value, inherits = TRUE)
        } else {
            assign(argLocal[[i]][1], argLocal[[i]][2], inherits = TRUE)
        }
    }
}
pkg <- scan(insts, "character")
## Check for github packages (throw away github username)
chk.git <- gsub(".*/", "", pkg)    
new.pkg <- pkg[!(chk.git %in% installed.packages()[, "Package"])]
if(!(length(new.pkg) == 0)){
    git.ind <- grep("/", new.pkg)
    if(length(git.ind) == 0){
        install.packages(new.pkg, dependencies = TRUE,
                         repos = "https://cran.csiro.au/")
    } else {
        devtools::install_github(new.pkg[git.ind])
    }
}
EOF
