#!/usr/bin/env Rscript
install.packages("optparse")
install.packages("neuRosim")
install.packages("oro.nifti")
library("optparse")
library("neuRosim")
library("oro.nifti")

option_list = list(
  make_option(c("-d", "--dim"), type="integer", default=64,
              help="the dimension of the images to generate (cubed, so it will be this on each side)", metavar="integer"),
  make_option(c("-s", "--snr"), type="integer", default=10,
              help="signal to noise ratio", metavar="integer"),
  make_option(c("-n", "--nscan"), type="integer", default=100,
              help="number of scans (images) to generate", metavar="integer"),
  make_option(c("-o", "--out"), type="character", default="synthetic-data",
              help="file to save the model to", metavar="character")
);



opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

## Lots of opportunities in here for cli variables. Need to figure out str -> int in R

TR <- 2
nscan <- 100
total <- TR * nscan
os1 <- seq(1, total, 40)
os2 <- seq(15, total, 40)
dur <- list(20, 7)
os <- list(os1, os2)
effect <- list(3, 10)

regions <- simprepSpatial(regions = 2, coord = list(c(10, 5, 24),
  c(53, 29, 24)), radius = c(10, 5), form = "sphere")

onset <- list(os, os)
duration <- list(dur, dur)
effect1 <- list(2, 9)
effect2 <- list(14, 8)
design2 <- simprepTemporal(regions = 2, onsets = onset,
  durations = duration, TR = TR, hrf = "double-gamma",
  effectsize = list(effect1, effect2), totaltime = total)

w <- c(0.3, 0.3, 0.01, 0.09, 0.1, 0.2)
data <- simVOLfmri(dim = c(opt$dim, opt$dim, opt$dim), base = 100, design = design2,
  image = regions, SNR = opt$snr, noise = "mixture", type = "rician", nscan= opt$nscan
  weights = w, verbose = FALSE)

writeNIfTI(data, filename = opt$out, verbose=TRUE)
