objects := $(wildcard R/*.R) DESCRIPTION
# man := $(wildcard man/*.Rd) NAMESPACE
dir := $(shell pwd)
version := $(shell grep "Version" DESCRIPTION | sed "s/Version: //")
pkg := $(shell grep "Package" DESCRIPTION | sed "s/Package: //")
tar := $(pkg)_$(version).tar.gz
checkLog := $(pkg).Rcheck/00check.log
citation := inst/CITATION
yr := $(shell date +"%Y")
dt := $(shell date +"%Y-%m-%d")

# rmd := vignettes/$(pkg)-intro.Rmd
# vignettes := vignettes/$(pkg)-intro.html
cprt := COPYRIGHT


.PHONY: check
check: $(checkLog)

.PHONY: build
build: $(tar)

# .PHONY: preview
# preview: $(vignettes)

$(tar): $(objects) updateMeta
	Rscript -e "library(methods); devtools::document();";
	R CMD build $(dir)

$(checkLog): $(tar)
	R CMD check --as-cran $(tar)

# $(vignettes): $(rmd)
#	Rscript -e "rmarkdown::render('$(rmd)')"

.PHONY: install
install: $(tar)
	R CMD INSTALL $(tar)

## update copyright year in HEADER, R script and date in DESCRIPTION
.PHONY: updateMeta
updateMeta: $(cprt)
	@sed -i "s/Copyright (C) 2011-[0-9]\{4\}/Copyright (C) 2011-$(yr)/" $(cprt)
	@for Rfile in R/*.R; do \
	if ! grep -q 'Copyright (C)' $$Rfile;\
	then cat $(cprt) $$Rfile > tmp;\
	mv tmp $$Rfile;\
	fi;\
	sed -i "s/Copyright (C) 2011-[0-9]*/Copyright (C) 2011-$(yr)/" $$Rfile;\
	done;
	@sed -i "s/Date: [0-9]\{4\}-[0-9]\{1,2\}-[0-9]\{1,2\}/Date: $(dt)/" DESCRIPTION
	@sed -i "s/version [0-9]\.[0-9]-[0-9]\(\.[0-9][0-9]*\)*/version $(version)/" $(citation)
	@sed -i "s/20[0-9]\{2\}/$(yr)/" $(citation)



.PHONY: clean
clean:
	rm -rf *~ */*~ src/*.o *.Rhistroy *.tar.gz *.Rcheck/ .\#*
