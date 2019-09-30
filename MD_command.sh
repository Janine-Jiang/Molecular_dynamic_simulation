#!/bin/sh

#  MD_command.sh
#  
#
#  Created by Qianjia on 30.09.18.
#  
gmx_mpi pdb2gmx -f bsla_wt_pH74_noH3.pdb -o bsla_wt_dio.gro -p bsla_wt_dio.top -water spce -ignh
choose force field 14 +enter
gmx_mpi editconf -f bsla_wt_dio.gro -o bsla_wt_dio_box.gro -c -d 1.2
gmx_mpi grompp -f em-vac-pme.mdp -c bsla_wt_dio_box.gro -p bsla_wt_dio.top -o em-vac.tpr
gmx_mpi mdrun -v -deffnm em-vac
gmx_mpi editconf -f dio_ATB.pdb -o dio_ATB.gro
gmx_mpi insert-molecules -f em-vac.gro -ci dio_ATB.gro -nmol 691 -o bsla_wt_dio_dio.gro
gmx_mpi insert-molecules -f em-vac.gro -ci dio_ATB.gro -nmol 691 -o bsla_wt_dio_dio.gro

vi bsla_wt_dio.top
(Change the file version)
(change below, one by one keep the oder) ; Include forcefield parameters
#include "/home/Mystuff/force_field/gromos54a7_atb.ff/forcefield.itp"
(Under this part, add green command, change yellow)
(; Include Position restraint file #ifdef POSRES
#include "posre.itp"
#endif )
; Include topology for dioxane (In the end, input “G” to go to the end, under) #include "/home/Mystuff/force_field/gromos54a7_atb.ff/dio_ATB.itp"
[ molecules ]
; Compound #miols
Protein_chain_A 1
G256 691

gmx_mpi solvate -cp bsla_wt_dio_dio.gro -cs spc216.gro -maxsol 4744 -p bsla_wt_dio.top -o bsla_wt_dio_water.gro
gmx_mpi grompp -f em-sol-pme.mdp -c bsla_wt_dio_water.gro -p bsla_wt_dio.top -o ion.tpr
gmx_mpi genion -s ion.tpr -o bsla_wt_dio_ion.gro -neutral -pname NA -nname CL -p bsla_wt_dio.top
15 + enter
#### 15 <SOL>
gmx_mpi grompp -f em-sol-pme.mdp -c bsla_wt_dio_ion.gro -p bsla_wt_dio.top -o em-sol.tpr
gmx_mpi mdrun -v -deffnm em-sol
gmx_mpi energy -f em-sol.edr -o bsla_wt_dio_potential.xvg
12 0
gmx_mpi grompp -f nvt-pr-md.mdp -c em-sol.gro -p bsla_wt_dio.top -o nvt-pr.tpr
gmx_mpi mdrun -v -deffnm nvt-pr
tail -n 25 nvt-pr.log (tail the log, show last 25 lines)
gmx_mpi energy -f nvt-pr.edr -o bsla_wt_dio_temperature.xvg
15 0
gmx_mpi grompp -f npt-pr-md.mdp -c nvt-pr.gro -t nvt-pr.cpt -p bsla_wt_dio.top -o npt-pr.tpr
gmx_mpi mdrun -v -deffnm npt-pr
gmx_mpi energy -f npt-pr.edr -o bsla_wt_dmso_pressure.xvg
16 0
gmx_mpi energy -f npt-pr.edr -o bsla_wt_dmso_density.xvg
22 0
gmx_mpi grompp -f npt-pr-mdrun.mdp -c npt-pr.gro -t npt-pr.cpt -p bsla_wt_dio.top -o npt-nopr.tpr
nohup gmx_mpi mdrun -v -deffnm npt-nopr
tail -n 25 npt-nopr.log
