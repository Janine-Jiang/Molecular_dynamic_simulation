#!/bin/sh

#  One_step_analysis.sh
#  
#
#  Created by Qianjia on 06.02.19.
#  


####prepare the gro and tpr file and index file for distance calculation
cd most_stable
for dir in `ls`
do
cd $dir
d=${dir}
if [ -f "*.pdb" ]
cp /home/fx158479/em-vac-pme.mdp ./
echo 14 | gmx_mpi pdb2gmx -f *.pdb -o ${d}.gro -p ${d}.top -water none
gmx_mpi editconf -f ${d}.gro -o ${d}_box.gro -c -d 1.2
gmx_mpi grompp -f em-vac-pme.mdp -c ${d}_box.gro -p ${d}.top -o em-vac.tpr
gmx_mpi make_ndx -f ${d}_box.gro -o distance_index.ndx << EOF
r12
r77
r78
r133
r156
q
EOF

#### distance between the active sites
###### (I12-N:87, M78-N:766), (S77-OG:762, H156-NE:1515), (D133-OD1:1284, H156-ND1:1509)
## gmx_mpi distance -f bsla_wt_box.gro -select 'atomnr 87 766' 'atomnr 762 1515' 'atomnr 1284 1509' -n index.ndx -oav distance.xvg
##r12 #residue ILE 12
##r78 # residue Met 78
##r77 #residue Serin 77
##r156 #residue His 156
##r133 #residue Aspartat 133
gmx_mpi distance -s em-vac.tpr -f ${d}_box.gro -n distance_index.ndx -select 'com of group "r_12" plus com of group "r_78"'  -oav /home/fx158479/result_analysis/resdistance_I12_M78/${d}_resdistance_I12_M78.xvg

gmx_mpi distance -s em-vac.tpr -f ${d}_box.gro -n distance_index.ndx -select 'com of group "r_77" plus com of group "r_156"'  -oav /home/fx158479/result_analysis/resdistance_S77_H156/${d}_resdistance_S77_H156.xvg

gmx_mpi distance -s em-vac.tpr -f ${d}_box.gro -n distance_index.ndx -select 'com of group "r_133" plus com of group "r_156"'  -oav /home/fx158479/result_analysis/resdistance_D133_H156/${d}_resdistance_D133_H156.xvg




## Rg The radius of gyration of a protein is a measure of its compactness. If a protein is stably folded, it will likely maintain a relatively steady value of Rg. If a protein unfolds, its Rg will change over time.    If the radius bigger than others it means the compactness is lower.
echo 1 | gmx_mpi gyrate -s em-vac.tpr -f ${d}_box.gro -o /home/fx158479/result_analysis/gyrate/${d}_gyrate.xvg



## RMSF based on amino acid and get average structure
## -res to caculate rmsf for each residue
## seems like the results don't make any sense in this case
#echo 1 | gmx_mpi rmsf -s em-vac.tpr -f bsla_wt_box.gro -o rmsf.xvg -res


## SASA to show the hydrophobicity of protein
## -o [<.xvg>](area.xvg) Total area as a function of time
## -or[<.xvg>](resarea.xvg) Average area per residue
## -oa[<.xvg>](atomarea.xvg) Average area per atom
echo 1 | gmx_mpi sasa -s em-vac.tpr -f ${d}_box.gro -or /home/fx158479/result_analysis/resasa/${d}_ressasa.xvg
echo 1 | gmx_mpi sasa -s em-vac.tpr -f ${d}_box.gro -o /home/fx158479/result_analysis/sasa/${d}_sasa.xvg -surface 'group "protein"' -output '"Hydrophobic" group "protein" and charge {-0.2 to 0.2}; "Hydrophilic" group "protein" and not charge {-0.2 to 0.2}; "Total" group "protein"'



## Internal hydrogen bond analysis
echo 1 1 | gmx_mpi hbond -s em-vac.tpr -f ${d}_box.gro -tu ns  -hbn ${d}_hydrogen_bond_protein_protein_index.ndx
echo 1 1 | gmx_mpi hbond -s em-vac.tpr -f ${d}_box.gro -tu ns  -hbm ${d}_hydrogen_bond_protein_protein_matrix.xpm
python readHBmap.py -hbm hydrogen_bond_protein_protein_matrix.xpm -hbn hydrogen_bond_protein_protein_index.ndx -f ${d}_box.gro -t 99 -op /home/fx158479/result_analysis/h_bond/${d}_hydrogen_bond_protein_protein_occupancy_pairs.dat

then
cd ..
else
cd ..
fi
done

