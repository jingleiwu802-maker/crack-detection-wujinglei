function mask = refineMask(rawMask, cfg)
%REFINEMASK Remove small components and bridge short crack gaps.

mask = bwareaopen(logical(rawMask), cfg.min_blob_area);
mask = imclose(mask, strel('disk', cfg.close_radius));
end

