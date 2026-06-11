# Multi Scan Closed Loop

This note documents the current `multi_scan_closedloop` workflow in [ImageFunctionPool.m](/abs/path/c:/MATLAB_Code/ImageFunctionPool.m).

## What It Does

`multi_scan_closedloop` is a tiled coarse-stage raster scan using the Attocube closed-loop `X/Y/Z` axes.

At each tile, the code:

1. Moves `Z` to a safe idle height.
2. Moves the coarse stage to the next `X/Y` tile.
3. Restores `Z` to the pre-move imaging height.
4. Runs a first image scan.
5. Finds the brightest spot in that first scan.
6. Checks the first-scan maximum PL against `trackz_min_pl`.
7. If the PL is too low:
   - skips `TrackZ`
   - skips the second scan
   - saves the first scan only
8. Otherwise:
   - moves the galvo fixed point to the brightest spot
   - runs `TrackZ` there
   - restores the original galvo fixed point
   - runs the second scan
   - saves the second scan only
9. Logs the saved image path together with the coarse-stage tile position.

The coarse-stage raster is serpentine:

- one `X` column at a time
- `Y` scans forward in one column and backward in the next

## Current GUI Behavior During Multi Scan

During `multi_scan_closedloop`, the code temporarily changes the GUI behavior to reduce overhead:

- forces `Fast Scan` on
- disables marker drawing
- disables live image updates during a single tile scan
- updates the displayed image only after the full image scan finishes

After multi-scan exits, the original GUI state is restored.

## User Settings In The Function

Near the top of `multi_scan_closedloop`, the user normally edits:

- `x_start`, `x_stop`, `Nx`
- `y_start`, `y_stop`, `Ny`
- `trackz_min_pl`
- `z_idle`
- `logDir`

These define:

- the coarse-stage scan rectangle in microns
- the number of tiles
- the PL threshold for deciding whether to do `TrackZ + second scan`
- the safe Z height for stage travel
- where the multi-scan CSV log is written

## What Gets Saved

Two kinds of data are saved:

### 1. Multi-scan CSV log

For each saved tile image, one row is appended to:

- `MultiImageScanLog/closedloop_scan_log_YYYYMMDD_HHMMSS.csv`

The CSV columns are:

- `timestamp`
- `ix`
- `iy`
- `x_um`
- `y_um`
- `file`

Meaning:

- `ix`, `iy` are tile indices in the logical raster grid
- `x_um`, `y_um` are the coarse-stage absolute positions in microns
- `file` is the full path to the image file that was actually saved for that tile

Important:

- if PL was below `trackz_min_pl`, the saved file is the first scan
- otherwise, the saved file is the second scan after `TrackZ`

### 2. Per-tile image files

Each tile image is saved in the normal confocal text format used by `ImageSaveImage`.

Each `.txt` image file contains:

- `VxRange in distance [um]`
- `VyRange in distance [um]`
- `VzRange`
- `DTRange`
- `Size: [NX NY]`
- the image data values
- notes
- acquisition time

These files can be read back by the existing MATLAB helper:

- `ReadImageFile(...)`

## How To Stitch The Tiles Into A Larger Image

There is no automatic mosaic builder in `multi_scan_closedloop` itself.

The intended workflow is:

1. Read the multi-scan CSV log.
2. For each CSV row, load the corresponding image file.
3. Use the coarse-stage `x_um`, `y_um` from the CSV as the tile center position in the large mosaic.
4. Use the local image axes from the tile file as the within-tile coordinates.
5. Place each tile onto a larger global canvas.
6. Blend overlaps by averaging, weighted averaging, or max projection.

## Important Warning About Stage Repeatability

For this setup, the coarse-stage repeatability is poor enough that the logged stage coordinates should be treated only as an initial guess.

That means:

- a naive stitch that places tiles only by the CSV `x_um`, `y_um` values will usually not look very good
- neighboring tiles can be visibly misregistered even when the scan grid itself was defined correctly
- the CSV stage positions are still useful, but mainly for finding approximate neighbors and initializing the mosaic

For stitching, you can assume:

- the repeatability error mainly produces translational shifts
- you do not need to model per-tile rotational correction as a first-order fix

So the practical stitching problem here is translation-only registration, not full rigid or affine registration.

## Recommended Stitching Strategy

Because the stage repeatability is poor, the recommended workflow is:

1. Use the CSV `x_um`, `y_um` values as initial tile centers.
2. Identify overlapping tile pairs from those approximate positions.
3. Estimate the best `x/y` translation correction from the tile overlap itself.
4. Solve for a globally consistent set of tile translations.
5. Render the corrected mosaic only after those translation offsets have been applied.

Good algorithm choices include:

- normalized cross-correlation on overlap regions
- phase correlation for translational alignment
- pairwise translation graph optimization or least-squares global refinement

If the overlap is reasonably large, even a simple translation-only overlap registration is usually much better than stage-only stitching.

## Recommended Stitching Coordinates

For each saved tile:

1. Load the tile file with `ReadImageFile(...)`.
2. Extract:
   - `IMG.Data`
   - `IMG.ContRange`
   - `IMG.FLRange`
3. Convert local tile coordinates to global coordinates by adding the coarse-stage tile center:

- `global_x = tile_x_center_um + local_x_um`
- `global_y = tile_y_center_um + local_y_um`

Where:

- `tile_x_center_um`, `tile_y_center_um` come from the CSV log
- `local_x_um`, `local_y_um` come from the image file ranges

## Important Orientation Check

You must verify the sign convention once before stitching the full dataset.

Depending on your microscope geometry, the correct mapping may instead need:

- `global_x = tile_x_center_um - local_x_um`
- `global_y = tile_y_center_um + local_y_um`

or another sign flip / axis swap.

Practical check:

1. Pick two neighboring tiles in `+X`.
2. Stitch just those two.
3. If the overlap is mirrored or moves the wrong way, flip the corresponding axis sign.

Do not assume the coarse-stage `+X/+Y` direction matches the image axes without checking.

## Suggested MATLAB Stitching Procedure

Minimal workflow:

1. Read the CSV log with `readtable`.
2. Loop over rows.
3. For each row:
   - call `ReadImageFile(file)`
   - compute local `x/y` vectors from `IMG.ContRange` and `IMG.FLRange`
   - map them into global coordinates using the logged stage center as an initial guess
   - refine the tile position by translation-only registration against overlapping neighbors
   - interpolate or place the tile into a global canvas
4. Blend overlaps.

For a first pass, simple averaging on a common global grid is usually enough after translation refinement.
Without that refinement, the final mosaic will often look visibly misaligned.

## Practical Notes

- If you are using APD with fast scan, the current fast path includes an empirical reverse-line correction for bidirectional scan lag.
- The saved tile file is the authoritative per-tile data product. Use the CSV only for tile placement metadata.
- The CSV file path column is the easiest way to identify exactly which image was saved at each tile.

## Summary

`multi_scan_closedloop` saves a set of per-tile image files plus one CSV log that records where each saved tile belongs in coarse-stage coordinates.

To build the final large mosaic:

- load the CSV
- load each saved tile
- use `x_um`, `y_um` only as an initial placement
- refine each tile with translation-only overlap registration
- verify axis orientation once
- blend overlaps into one global image
