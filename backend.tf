terraform {
  backend "gcs" {
    bucket = "mikelaramie-sadacedemos-tf-state"
    prefix = "vigilant-bassoon/"
  }
}
