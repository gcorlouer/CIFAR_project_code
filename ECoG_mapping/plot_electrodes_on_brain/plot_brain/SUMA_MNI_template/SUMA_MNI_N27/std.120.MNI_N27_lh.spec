# MapIcosahedron generated spec file
#History: [ziad@eomer.nimh.nih.gov: Tue Aug  6 12:44:24 2013] MapIcosahedron -spec MNI_N27_lh.spec -ld 120 -dset_map lh.thickness.gii.dset -dset_map lh.curv.gii.dset -dset_map lh.sulc.gii.dset -prefix std.120.

#define the group
	Group = MNI_N27

#define various States
	StateDef = std.smoothwm
	StateDef = std.pial
	StateDef = std.inflated
	StateDef = std.full.patch.3d
	StateDef = std.full.flat.patch.3d
	StateDef = std.sphere
	StateDef = std.white
	StateDef = std.sphere.reg
	StateDef = std.inf_200

NewSurface
	SurfaceFormat = ASCII
	SurfaceType = GIFTI
	SurfaceName = ./std.120.lh.smoothwm.gii
	LocalDomainParent = ./SAME
	LabelDset = ./std.120.lh.aparc.a2009s.annot.niml.dset
	SurfaceState = std.smoothwm
	EmbedDimension = 3
	Anatomical = Y
	LocalCurvatureParent = ./SAME

NewSurface
	SurfaceFormat = ASCII
	SurfaceType = GIFTI
	SurfaceName = ./std.120.lh.pial.gii
	LocalDomainParent = ./std.120.lh.smoothwm.gii
	SurfaceState = std.pial
	EmbedDimension = 3
	Anatomical = Y
	LocalCurvatureParent = ./std.120.lh.smoothwm.gii

NewSurface
	SurfaceFormat = ASCII
	SurfaceType = GIFTI
	SurfaceName = ./std.120.lh.inflated.gii
	LocalDomainParent = ./std.120.lh.smoothwm.gii
	SurfaceState = std.inflated
	EmbedDimension = 3
	Anatomical = N
	LocalCurvatureParent = ./std.120.lh.smoothwm.gii

NewSurface
	SurfaceFormat = ASCII
	SurfaceType = GIFTI
	SurfaceName = ./std.120.lh.full.patch.3d.gii
	LocalDomainParent = ./std.120.lh.smoothwm.gii
	SurfaceState = std.full.patch.3d
	EmbedDimension = 3
	Anatomical = N
	LocalCurvatureParent = ./std.120.lh.smoothwm.gii

NewSurface
	SurfaceFormat = ASCII
	SurfaceType = GIFTI
	SurfaceName = ./std.120.lh.full.flat.patch.3d.gii
	LocalDomainParent = ./std.120.lh.smoothwm.gii
	SurfaceState = std.full.flat.patch.3d
	EmbedDimension = 2
	Anatomical = N
	LocalCurvatureParent = ./std.120.lh.smoothwm.gii

NewSurface
	SurfaceFormat = ASCII
	SurfaceType = GIFTI
	SurfaceName = ./std.120.lh.sphere.gii
	LocalDomainParent = ./std.120.lh.smoothwm.gii
	SurfaceState = std.sphere
	EmbedDimension = 3
	Anatomical = N
	LocalCurvatureParent = ./std.120.lh.smoothwm.gii

NewSurface
	SurfaceFormat = ASCII
	SurfaceType = GIFTI
	SurfaceName = ./std.120.lh.white.gii
	LocalDomainParent = ./std.120.lh.smoothwm.gii
	SurfaceState = std.white
	EmbedDimension = 3
	Anatomical = Y
	LocalCurvatureParent = ./std.120.lh.smoothwm.gii

NewSurface
	SurfaceFormat = ASCII
	SurfaceType = GIFTI
	SurfaceName = ./std.120.lh.sphere.reg.gii
	LocalDomainParent = ./std.120.lh.smoothwm.gii
	SurfaceState = std.sphere.reg
	EmbedDimension = 3
	Anatomical = N
	LocalCurvatureParent = ./std.120.lh.smoothwm.gii

NewSurface
	SurfaceFormat = ASCII
	SurfaceType = GIFTI
	SurfaceName = ./std.120.lh.inf_200.gii
	LocalDomainParent = ./std.120.lh.smoothwm.gii
	SurfaceState = std.inf_200
	EmbedDimension = 3
	Anatomical = N
	LocalCurvatureParent = ./std.120.lh.smoothwm.gii
