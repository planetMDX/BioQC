library(BioQC)

## readGmt
context("Read gmt file into a GmtList object")
testFile <- system.file("extdata/test.gmt", package="BioQC")
testGmt <- readGmt(testFile)
expGmt <- list(list(name="GS_A", desc="TestGeneSet_A", genes=c("AKT1", "AKT2", "AKT3")),
               list(name="GS_B", desc="TestGeneSet_B", genes=c("MAPK1", "MAPK3", "MAPK8")),
               list(name="GS_C_UP", desc="TestGeneSet_C", genes=c("ERBB2", "ERBB3")),
               list(name="GS_C_DN", desc="TestGeneSet_C", genes=c("EGFR", "ERBB4")),
               list(name="GS_D_UP", desc="TestGeneSet_D", genes=c("GATA2", "GATA4")),
               list(name="GS_D_DN", desc="TestGeneSet_D", genes=c("GATA1", "GATA3")),
               list(name="GS_E_DN", desc="TestGeneSet_E", genes=c("TSC1", "TSC2")))
test_that("readGmt",{
             expect_equivalent(expGmt, testGmt)
         })

context("Read gmt file into a SignedGenesets object")
testSignedGenesets <- readSignedGmt(testFile, nomatch="pos")
expSignedGenesets <- list(list(name="GS_A", pos=c("AKT1", "AKT2", "AKT3"), neg=NULL),
                          list(name="GS_B", pos=c("MAPK1", "MAPK3", "MAPK8"), neg=NULL),
                          list(name="GS_C", pos=c("ERBB2", "ERBB3"), neg=c("EGFR", "ERBB4")),
                          list(name="GS_D", pos=c("GATA2", "GATA4"), neg=c("GATA1", "GATA3")),
                          list(name="GS_E", pos=NULL, neg=c("TSC1", "TSC2")))
test_that("readSignedGmt", {
              expect_equal(expSignedGenesets, testSignedGenesets@.Data)
          })

## as.gmtlist
context("Convert a list of gene symbols into a gmtlist object")
testVec <- list(GeneSet1=c("AKT1", "AKT2"),
                GeneSet2=c("MAPK1", "MAPK3"),
                GeneSet3=NULL)
testVecGmtlist <- as.gmtlist(testVec)
expVecGmtlist <- list(GeneSet1=list(name="GeneSet1", desc=NULL, genes=c("AKT1", "AKT2")),
                      GeneSet2=list(name="GeneSet2", desc=NULL, genes=c("MAPK1", "MAPK3")),
                      GeneSet3=list(name="GeneSet3", desc=NULL, genes=NULL))

testVecGmtlist.desc <- as.gmtlist(testVec, desc=c("GS1", "GS2", "GS3"))
expVecGmtlist.desc <- list(GeneSet1=list(name="GeneSet1", desc="GS1", genes=c("AKT1", "AKT2")),
                      GeneSet2=list(name="GeneSet2", desc="GS2", genes=c("MAPK1", "MAPK3")),
                      GeneSet3=list(name="GeneSet3", desc="GS3", genes=NULL))
test_that("as.gmtlist",{
              expect_equivalent(testVecGmtlist, expVecGmtlist)
              expect_equivalent(testVecGmtlist.desc, expVecGmtlist.desc)
         })

## gmtlist2signedGenesets
context("Convert gmtlist (a memory-copy of a GMT file) to a list of signed gene sets")

testInputList <- list(list(name="GeneSetA_UP",genes=LETTERS[1:3]),
                      list(name="GeneSetA_DN", genes=LETTERS[4:6]),
                      list(name="GeneSetB", genes=LETTERS[2:4]),
                      list(name="GeneSetC_DN", genes=LETTERS[1:3]),
                      list(name="GeneSetD_UP", genes=LETTERS[1:3]))
outList.ignore <- gmtlist2signedGenesets(testInputList, nomatch="ignore")
outList.pos <- gmtlist2signedGenesets(testInputList, nomatch="pos")
outList.neg <- gmtlist2signedGenesets(testInputList, nomatch="neg")

exp.ignore <- list("GeneSetA"=list(name="GeneSetA", pos=LETTERS[1:3], neg=LETTERS[4:6]),
                   "GeneSetB"=list(name="GeneSetB", pos=NULL, neg=NULL),
                   "GeneSetC"=list(name="GeneSetC", pos=NULL, neg=LETTERS[1:3]),
                   "GeneSetD"=list(name="GeneSetD", pos=LETTERS[1:3], neg=NULL))

exp.pos <- list("GeneSetA"=list(name="GeneSetA", pos=LETTERS[1:3], neg=LETTERS[4:6]),
                "GeneSetB"=list(name="GeneSetB", pos=LETTERS[2:4], neg=NULL),
                "GeneSetC"=list(name="GeneSetC", pos=NULL, neg=LETTERS[1:3]),
                "GeneSetD"=list(name="GeneSetD", pos=LETTERS[1:3], neg=NULL))

exp.neg <- list("GeneSetA"=list(name="GeneSetA", pos=LETTERS[1:3], neg=LETTERS[4:6]),
                "GeneSetB"=list(name="GeneSetB",pos=NULL, neg=LETTERS[2:4]),
                "GeneSetC"=list(name="GeneSetC", pos=NULL, neg=LETTERS[1:3]),
                "GeneSetD"=list(name="GeneSetD", pos=LETTERS[1:3], neg=NULL))

test_that("gmtlist2signedGenesets, ignore non-matching genesets", {
              expect_equivalent(outList.ignore, exp.ignore)
          })

test_that("gmtlist2signedGenesets, ignore non-matching as positive", {
             expect_equivalent(outList.pos, exp.pos)
         })
test_that("gmtlist2signedGenesets, ignore non-matching as negative", {
             expect_equivalent(outList.neg, exp.neg)
         })

## readSignedGmt
context("Read in gmt file into a signed_genesets object")
testSignedGenesets.ignore <- readSignedGmt(testFile, nomatch="ignore")
testSignedGenesets.pos <- readSignedGmt(testFile, nomatch="pos")
testSignedGenesets.neg <- readSignedGmt(testFile, nomatch="neg")

expSignedGenesets.ignore <- list(GS_A=list(name="GS_A", pos=NULL, neg=NULL),
                                 GS_B=list(name="GS_B", pos=NULL, neg=NULL),
                                 GS_C=list(name="GS_C", pos=c("ERBB2", "ERBB3"), neg=c("EGFR", "ERBB4")),
                                 GS_D=list(name="GS_D", pos=c("GATA2", "GATA4"), neg=c("GATA1", "GATA3")),
                                 GS_E=list(name="GS_E", pos=NULL, neg=c("TSC1", "TSC2")))
expSignedGenesets.pos <- list(GS_A=list(name="GS_A", pos=c("AKT1", "AKT2", "AKT3"), neg=NULL),
                              GS_B=list(name="GS_B", pos=c("MAPK1", "MAPK3", "MAPK8"), neg=NULL),
                              GS_C=list(name="GS_C", pos=c("ERBB2", "ERBB3"), neg=c("EGFR", "ERBB4")),
                              GS_D=list(name="GS_D", pos=c("GATA2", "GATA4"), neg=c("GATA1", "GATA3")),
                              GS_E=list(name="GS_E", pos=NULL, neg=c("TSC1", "TSC2")))
expSignedGenesets.neg <- list(GS_A=list(name="GS_A", pos=NULL, neg=c("AKT1", "AKT2", "AKT3")),
                              GS_B=list(name="GS_B", pos=NULL, neg=c("MAPK1", "MAPK3", "MAPK8")),
                              GS_C=list(name="GS_C", pos=c("ERBB2", "ERBB3"), neg=c("EGFR", "ERBB4")),
                              GS_D=list(name="GS_D", pos=c("GATA2", "GATA4"), neg=c("GATA1", "GATA3")),
                              GS_E=list(name="GS_E", pos=NULL, neg=c("TSC1", "TSC2")))
test_that("readSignedGmt, nomatch ingore",{
              expect_equivalent(testSignedGenesets.ignore, expSignedGenesets.ignore)
          })
test_that("readSignedGmt, nomatch pos",{
              expect_equivalent(testSignedGenesets.pos, expSignedGenesets.pos)
          })
test_that("readSignedGmt, nomatch neg",{
              expect_equivalent(testSignedGenesets.neg, expSignedGenesets.neg)
          })
