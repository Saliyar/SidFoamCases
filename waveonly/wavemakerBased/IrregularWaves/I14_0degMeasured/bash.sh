#!/bin/sh
### General options
#BSUB -J FoamwaveTank
#BSUB -n 4
#BSUB -R "span[ptile=4]"
#BSUB -W 48:00
#BSUB -R "select[avx512]"
#BSUB -o Output_%J.out
#BSUB -e Error_%J.err

# Load modules cleanly
module purge

#module load mpi/4.0.7-gcc-8.5.0-binutils-2.36.1
module load mpi/4.1.6-gcc-11.4.0-binutils-2.40  # Uncomment if needed
module load OpenFoam/v2206/gcc-11.4.0-binutils-2.40-openmpi-4.1.6

# Source OpenFOAM environment
#source /zhome/19/7/191420/OpenFOAM/OpenFOAM-5.x/etc/bashrc
#source /appl/OpenFOAM/5.0/XeonE5-2660v3/gcc-6.3.0/OpenFOAM-5.0/etc/bashrc

# Ensure correct paths
#export PATH=$HOME/OpenFOAM/OpenFOAM-5.x/platforms/linux64GccDPInt32Opt/bin:$PATH
#export LD_LIBRARY_PATH=$HOME/OpenFOAM/OpenFOAM-5.x/platforms/linux64GccDPInt32Opt/lib:$LD_LIBRARY_PATH

# Run OpenFOAM processes
#setFields | tee log.setfields
#decomposePar | tee log.decompose
#/appl9/gcc/8.5.0-binutils-2.36.1/openmpi/4.0.7-lsf10-alma92/bin/mpirun -np 4 foamStarSwense -parallel | tee log.foam
#mpirun -np 16 foamStar -parallel | tee log.foam

blockMesh
renumberMesh -overwrite
mkdir 0
cp -pr 0.orig/* 0/
cp -pr 0.orig/alpha.water 0/alpha.water
setFields
topoSet -dict ./system/topoSetDict_absorber
setsToZones -noFlipMap
foamToVTK -cellZone absorber
decomposePar
mpirun -np 4 interIsoFoam -parallel | tee log.foam
