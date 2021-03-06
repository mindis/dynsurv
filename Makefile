objects := $(wildcard R/*.R) DESCRIPTION
# man := $(wildcard man/*.Rd) NAMESPACE
version := $(shell grep "Version" DESCRIPTION | sed "s/Version: //")
pkg := $(shell grep "Package" DESCRIPTION | sed "s/Package: //")
tar := $(pkg)_$(version).tar.gz
checkLog := $(pkg).Rcheck/00check.log
citation := inst/CITATION
yr := $(shell date +"%Y")
dt := $(shell date +"%Y-%m-%d")

cprt := COPYRIGHT
# rmd := vignettes/$(pkg)-intro.Rmd
# vignettes := vignettes/$(pkg)-intro.html


.PHONY: check
check: $(checkLog)

.PHONY: build
build: $(tar)

.PHONY: install
install: $(tar)
	R CMD INSTALL $(tar)

$(tar): $(objects)
	@if [ "$$(uname)" == "Darwin" ];\
	then echo "remeber to update date and version number";\
	else make -s updateMeta;\
	fi;\
	Rscript -e "library(methods); devtools::document();";
	R CMD build .

$(checkLog): $(tar)
	R CMD check --as-cran $(tar)

# .PHONY: preview
# preview: $(vignettes)

# $(vignettes): $(rmd)
#	Rscript -e "rmarkdown::render('$(rmd)')"

## update copyright year in HEADER, R script and date in DESCRIPTION
.PHONY: updateMeta
updateMeta:
	@echo "Updating date, version, and copyright year"
	@sed -i "s/Copyright (C) 2011-*[0-9]*/Copyright (C) 2011-$(yr)/" $(cprt)
	@for Rfile in R/*.R; do \
	if ! grep -q 'Copyright (C)' $$Rfile;\
	then cat $(cprt) $$Rfile > tmp;\
	mv tmp $$Rfile;\
	fi;\
	sed -i "s/Copyright (C) 2011-*[0-9]*/Copyright (C) 2011-$(yr)/" $$Rfile;\
	done;
	@sed -i "s/Date: [0-9]\{4\}-[0-9]\{1,2\}-[0-9]\{1,2\}/Date: $(dt)/" DESCRIPTION
	@sed -i "s/version [0-9]\.[0-9]-[0-9]\(\.[0-9][0-9]*\)*/version $(version)/" $(citation)
	@sed -i "s/20[0-9]\{2\}/$(yr)/" $(citation)

## make tags
.PHONY: TAGS
TAGS:
	Rscript -e "utils::rtags(path = 'R', ofile = 'TAGS')"
	gtags

.PHONY: clean
clean:
	rm -rf *~ */*~ src/*.o *.Rhistroy *.tar.gz *.Rcheck/ .\#*
