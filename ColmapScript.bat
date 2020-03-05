function pause(){
   read -p "$*"
}
::These parameters are specific to computer

::Store current Directory:
set currDir=%CD%

::get folder name as variable
SET "MYDIR=%~p0"
set MYDIR1=%MYDIR:~0,-1%
for %%f in (%MYDIR1%) do set myfolder=%%~nxf

:: Set colmap directory (change this to where you've downloaded colmap, replace 'dev' with version number if necessary):
set colDir=E:\COLMAP-dev-windows\bin\colmap.exe

:: Set openMVS directory (change this to where you've downloaded openMVS)
set oMVS=E:\openMVS-master

:: Set Working Directory (I create a temporary folder on my D drive to process data in)
set workDir=E:\Senior Design\ColMapWork

:: Set Dataset path
set DATASET_PATH=E:\Senior Design\ColMapWork

set TEST_PATH=E:\Senior Design\ColMapWork\Dump

mkdir "%TEST_PATH%"
mkdir "%workDir%" 
mkdir "%workDir%\images" 
mkdir "%workDir%\sparse"
mkdir "%workDir%\dense" 
mkdir "%workDir%\sparse\Custom"
mkdir "%workDir%\sparse\Custom\sparse"  
cd /d images
copy *.jpg "%workDir%\images" 
cd /d "%workDir%"

set sparseDir=E:\Senior Design\ColMapWork\sparse\Custom

%colDir% feature_extractor --database_path database.db --image_path "%workDir%\images"

pause 'Feature Extraction COMPLETE Press [Enter] key to continue...'

%colDir% exhaustive_matcher --database_path database.db
::%colDir% spatial_matcher --database_path database.db
pause 'Matcher COMPLETE Press [Enter] key to continue...'

::%colDir% mapper --database_path database.db --image_path "%workDir%\images" --output_path "%sparseDir%\0"
::pause 'Mapper COMPLETE Press [Enter] key to continue...'

%colDir% point_triangulator --database_path database.db --image_path "%workDir%\images" --input_path "%sparseDir%\sparse" --output_path "%sparseDir%"
pause 'Point Triangulator COMPLETE Press [Enter] key to continue...'

%colDir% image_undistorter --image_path "%workDir%\images" --input_path "%sparseDir%" --output_path "%workDir%\dense" 
pause 'Image Undistorter COMPLETE Press [Enter] key to continue...'

%colDir% patch_match_stereo --workspace_path "%workDir%\dense"
pause 'Press [Enter] key to continue...'

%colDir% stereo_fusion --workspace_path "%workDir%\dense" --output_path "%workDir%\dense\fused.ply"
pause 'Press [Enter] key to continue...'

::%colDir% mapper --database_path database.db --image_path %workDir%\images --output_path "%workDir%\sparse"
::pause 'Press [Enter] key to continue...'


%colDir% model_converter --input_path "%sparseDir%\sparse" --output_path model.nvm --output_type NVM
:: %colDir% model_converter --input_path sparse\0 --output_path model.nvm --output_type NVM
%oMVS%\InterfaceVisualSFM.exe model.nvm
%oMVS%\DensifyPointCloud.exe model.mvs
pause 'Press [Enter] key to continue...'
%oMVS%\ReconstructMesh.exe model_dense.mvs
%oMVS%\RefineMesh.exe --resolution-level 1 model_dense_mesh.mvs
%oMVS%\TextureMesh.exe --export-type obj -o %myfolder%.obj model_dense_mesh_refine.mvs

mkdir %currDir%\model\
copy *.obj %currDir%\model\
copy *.mtl %currDir%\model\
copy *Kd.jpg %currDir%\model\

cd %currDir%

::If you want to automate removal of the working folder, use the following line.
::Don't use it if you want to keep intermediate steps.
::rmdir /S /Q %workDir%