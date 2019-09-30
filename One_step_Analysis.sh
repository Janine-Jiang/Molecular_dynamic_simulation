#!/usr/bin/env zsh


### filename= E65H_dio_1

## change the file type
echo 0 0 | gmx_mpi trjconv -f npt-nopr.trr -s npt-nopr.tpr -o npt-nopr.xtc -pbc nojump -ur compact -center   

## center 
echo 1 0 | gmx_mpi trjconv -s npt-nopr.tpr -f  npt-nopr.xtc -o npt-nopr_noPBC.xtc -pbc whole -ur compact -center      

## RMSD  Define measure of „distance“ of 2 molecules. Applications: Find timepoints, when conformation changes；Define folding procedures 
### Cα root mean squared deviation (RMSD) of the entire protein compared to the simulation’s starting structure was used both as a measure of protein stability and as a means to monitor significant changes from the crystal structure. 
echo 4 4 | gmx_mpi rms -s em-sol.tpr -f npt-nopr_noPBC.xtc -o rmsd_em-sol_E65H_dio_1.xvg -tu ns
#### (calculate RMSD relative to the crystal structure）

## Rg The radius of gyration of a protein is a measure of its compactness. If a protein is stably folded, it will likely maintain a relatively steady value of Rg. If a protein unfolds, its Rg will change over time.    If the radius bigger than others it means the compactness is lower. 
echo 1 | gmx_mpi gyrate -s npt-nopr.tpr -f npt-nopr_noPBC.xtc -o gyrate_E65H_dio_1.xvg

## RMSF based on amino acid and get average structure last 40ns
echo 1 | gmx_mpi rmsf -s npt-nopr.tpr -f npt-nopr_noPBC.xtc -b 60000 -o rmsf_res_E65H_dio_1.xvg -oq bfactor_structure_rmsf_E65H_dio_1.pdb -res

## g_cluster analyse the cluster to compare the structure
echo 1 1 | gmx_mpi rms -f npt-nopr_noPBC.xtc -s npt-nopr.tpr -m rmsd-matrix_E65H_dio_1.xpm -b 60000
echo 1 1 | gmx_mpi cluster -s npt-nopr.tpr -f npt-nopr_noPBC.xtc -dm rmsd-matrix_E65H_dio_1.xpm -dist cluster_rms-distribution_E65H_dio_1.xvg -o clusters_E65H_dio_1.xpm -sz cluster-sizes_E65H_dio_1.xvg -cl cluster_E65H_dio_1.pdb -cutoff 0.25 -method gromos -b 60000

## SASA to show the hydrophobicity of protein
## -o [<.xvg>](area.xvg) Total area as a function of time
## -or[<.xvg>](resarea.xvg) Average area per residue
## -oa[<.xvg>](atomarea.xvg) Average area per atom
echo 1 | gmx_mpi sasa -s npt-nopr.tpr -f npt-nopr_noPBC.xtc -or resarea_definetime_E65H_dio_1.xvg -oa atomarea_definetime_E65H_dio_1.xvg -b 60000
echo 1 | gmx_mpi sasa -s npt-nopr.tpr -f npt-nopr_noPBC.xtc -b 60000 -o area_definetime_odg_E65H_dio_1.xvg -odg -surface 'group "protein"' -output '"Hydrophobic" group "protein" and charge {-0.2 to 0.2}; "Hydrophilic" group "protein" and not charge {-0.2 to 0.2}; "Total" group "protein"'

## Second structure change
echo 1 | gmx_mpi do_dssp -s npt-nopr.tpr -f npt-nopr_noPBC.xtc -o dssp_E65H_dio_1.xpm
gmx_mpi xpm2ps -f dssp_E65H_dio_1.xpm -o dssp_E65H_dio_1.eps -by 2
ps2pdf dssp_E65H_dio_1.eps  dssp_E65H_dio_1.pdf

## Internal hydrogen bond analysis
cp /home/Software/readHBmap.py /home/WP5-1/E65H_dio/E65H_dio_1
echo 1 1 | gmx_mpi hbond -s npt-nopr.tpr -f npt-nopr_noPBC.xtc -tu ns  -hbn hydrogen_bond_protein_protein_index_E65H_dio_1.ndx
echo 1 1 | gmx_mpi hbond -s npt-nopr.tpr -f npt-nopr_noPBC.xtc -tu ns  -hbm hydrogen_bond_protein_protein_matrix_E65H_dio_1.xpm
python readHBmap.py -hbm hydrogen_bond_protein_protein_matrix_E65H_dio_1.xpm -hbn hydrogen_bond_protein_protein_index_E65H_dio_1.ndx -f npt-nopr.gro  -t 95 -dt 100 -o hydrogen_bond_protein_protein_occupancy_t_95_E65H_dio_1.xvg -op hydrogen_bond_protein_protein_occupancy_pairs_t_95_E65H_dio_1.dat




rmsd_em-sol_E65H_dio_1.xvg


