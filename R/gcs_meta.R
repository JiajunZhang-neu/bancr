#' Download a compiled BANC meta feather from GCS
#'
#' @description Internal helper. Resolves the public GCS path
#' `gs://lee-lab_brain-and-nerve-cord-fly-connectome/compiled_data/<slug>/<slug>_meta.feather`,
#' caches a local copy under `tools::R_user_dir("bancr", "cache")`, and
#' returns the full `arrow::read_feather()` data frame. Used as the
#' default backing store for [`banc_meta()`] / [`banc_meta_create_cache()`]
#' and [`franken_meta()`].
#'
#' @details The compiled meta tables live at
#' \url{https://lee-lab.banc.community/data/compiled_data} (a public
#' bucket described in the BANC dataset documentation). Slugs follow the
#' `<dataset>_<version>` pattern used in
#' `gs://lee-lab_brain-and-nerve-cord-fly-connectome/compiled_data/`,
#' e.g. `banc_888`, `fafb_783`, `manc_121`, `hemibrain_121`, `malecns_09`.
#'
#' @param slug Character. Dataset slug naming the `compiled_data/<slug>/`
#'   directory (and the `<slug>_meta.feather` file within it).
#' @param overwrite Logical. If `TRUE` re-download even if a cached copy
#'   already exists. Default `FALSE`.
#'
#' @return A data frame with all columns of the requested meta feather.
#' @keywords internal
#' @noRd
banc_gcs_meta_feather <- function(slug, overwrite = FALSE) {
  if (!requireNamespace("arrow", quietly = TRUE)) {
    stop("Package 'arrow' is required to read .feather meta tables. ",
         "Install with: install.packages('arrow')")
  }
  cache_dir <- tools::R_user_dir("bancr", "cache")
  if (!dir.exists(cache_dir)) dir.create(cache_dir, recursive = TRUE)
  target <- file.path(cache_dir, sprintf("%s_meta.feather", slug))
  if (!file.exists(target) || isTRUE(overwrite)) {
    url <- sprintf(
      "https://storage.googleapis.com/lee-lab_brain-and-nerve-cord-fly-connectome/compiled_data/%s/%s_meta.feather",
      slug, slug
    )
    message("Downloading ", basename(target), " from GCS ...")
    utils::download.file(url, target, mode = "wb", quiet = FALSE)
  }
  arrow::read_feather(target)
}
