Filter gemini DB by appropriate runfolders and grab Xnumber & DOB columns (data must not leave Trust network)

dx select 003_TelomerecatDev

dx cd /AdamReplicates/data/tsoe

# copy tsoe bams to runfolder directories in TC project
IFS=$'\n'
for i in $(dx find projects --name "*TSOE*"); do 
    projectID=$(printf $i | awk -F " " '{print $1}'); 
    proName=$(printf $i | awk -F " " '{print $3}'); 
    dx mkdir $proName; 
    dx cd $proName; 
    for j in $(dx find data --project $projectID --name "*markdup.bam" --brief); do 
        dx cp $j .; 
    done; 
    dx cd /AdamReplicates/data/tsoe; 
done

dx cd /AdamReplicates/data/twe

# specify WES runs to use as there are more than 5 in DNAnexus
twe="project-G6941GQ4QVvgXjP6Bx57yJY9 : 002_211112_A01303_0039_AHLWLLDRXY_TWE (CONTRIBUTE),project-G4b2PJj4fyv532vYF3kVzx0f : 002_210826_A01295_0020_AHKK3TDRXY_TWE (CONTRIBUTE),project-G618GZQ4F21G2vg4FjKBGP2q : 002_211101_A01303_0037_AH5257DMXY_TWE (CONTRIBUTE),project-G6946J04y4FgXjP6Bx57yK36 : 002_211112_A01303_0040_BHLWHHDRXY_TWE (CONTRIBUTE),project-G6Jf4gQ4z2f181P17jB4B892 : 002_211118_A01295_0036_AH5CK3DMXY_TWE (CONTRIBUTE)"

# copy TWE bams to runfolder directories in TC project
IFS=$','
for i in $twe; do 
    IFS=$','; 
    projectID=$(printf $i | awk -F " " '{print $1}'); 
    proName=$(printf $i | awk -F " " '{print $3}'); IFS=$'\n'; 
    dx mkdir $proName; 
    dx cd $proName; 
    for j in $(dx find data --project $projectID --name "*markdup.bam" --brief); do 
        dx cp $j .; 
    done; 
    dx cd /AdamReplicates/data/twe; 
done

# run TC on each tsoe bam x3
IFS=$'\n'
for i in $(dx find data --path /AdamReplicates/data/tsoe --name "*.bam"); do 
    proName=$(printf $i | awk -F " " '{print $6}' | awk -F "/" '{print $5}'); 
    fileID=$(printf $i | awk -F " " '{print $6}'); 
    for j in 1 2 3; do
        dx mkdir -p /AdamReplicates/output/tsoe/$proName/$j; 
        dx run applet-G5KgYj0406xzyJb1BqQ4FkXq -ibam_input=$fileID -isamtools_docker=file-G4g6YJQ406xYBZbKK9zyBVyv -itelomerecat_docker=file-G4g2Kvj406xb3VfYKvZv1QP1 --destination /AdamReplicates/output/tsoe/$proName/$j -y; 
    done;
done

# Do same for TWE (WES) - watch out for duplicates!
for i in $(dx find data --path /AdamReplicates/data/twe --name "*.bam"); do 
    proName=$(printf $i | awk -F " " '{print $6}' | awk -F "/" '{print $5}'); 
    fileID=$(printf $i | awk -F " " '{print $6}'); 
    for j in 1 2 3; do
        dx mkdir -p /AdamReplicates/output/twe/$proName/$j; 
        dx run applet-G5KgYj0406xzyJb1BqQ4FkXq -ibam_input=$fileID -isamtools_docker=file-G4g6YJQ406xYBZbKK9zyBVyv -itelomerecat_docker=file-G4g2Kvj406xb3VfYKvZv1QP1 --destination /AdamReplicates/output/twe/$proName/$j -y; 
    done;
done


# Grab telbams for next step
mkdir -p ~/Dev/telomere/AdamReplicates/telbams/tsoe
cd  ~/Dev/telomere/AdamReplicates/telbams/tsoe
for i in $(dx ls /AdamReplicates/output/tsoe); do echo $i; for j in $(dx ls /AdamReplicates/output/tsoe/$i); do echo $j; mkdir -p $i/$j; for k in $(dx find data --name "*telbam.bam" --path /AdamReplicates/output/tsoe/$i/$j --brief); do dx download $k -o $i/$j/; done; done; done
mkdir -p ~/Dev/telomere/AdamReplicates/telbams/twe
cd  ~/Dev/telomere/AdamReplicates/telbams/twe
for i in $(dx ls /AdamReplicates/output/twe); do echo $i; for j in $(dx ls /AdamReplicates/output/twe/$i); do echo $j; mkdir -p $i/$j; for k in $(dx find data --name "*telbam.bam" --path /AdamReplicates/output/twe/$i/$j --brief); do dx download $k -o $i/$j/; done; done; done

# For each set, run telomerecat with batch correction, both with and without read length limit

for i in $(ls ~/Dev/telomere/AdamReplicates/telbams/tsoe); do for j in $(ls ~/Dev/telomere/AdamReplicates/telbams/tsoe/$i); do cd ~/Dev/telomere/AdamReplicates/telbams/tsoe/$i/$j; mkdir -p ~/Dev/telomere/AdamReplicates/output/tsoe/$i/$j; telbams=$(ls); telomerecat telbam2length -e -v 2 --output ~/Dev/telomere/AdamReplicates/output/tsoe/$i/$j/telomerecat_length.csv $telbams; done; done

for i in $(ls ~/Dev/telomere/AdamReplicates/telbams/tsoe); do for j in $(ls ~/Dev/telomere/AdamReplicates/telbams/tsoe/$i); do cd ~/Dev/telomere/AdamReplicates/telbams/tsoe/$i/$j; mkdir -p ~/Dev/telomere/AdamReplicates/output/tsoe/$i/$j; telbams=$(ls); telomerecat telbam2length -e -t 75 -v 2 --output ~/Dev/telomere/AdamReplicates/output/tsoe/$i/$j/telomerecat_length_75.csv $telbams; done; done

for i in $(ls ~/Dev/telomere/AdamReplicates/telbams/twe); do for j in $(ls ~/Dev/telomere/AdamReplicates/telbams/twe/$i); do cd ~/Dev/telomere/AdamReplicates/telbams/twe/$i/$j; mkdir -p ~/Dev/telomere/AdamReplicates/output/twe/$i/$j; telbams=$(ls); telomerecat telbam2length -e -v 2 --output ~/Dev/telomere/AdamReplicates/output/twe/$i/$j/telomerecat_length.csv $telbams; done; done

for i in $(ls ~/Dev/telomere/AdamReplicates/telbams/twe); do for j in $(ls ~/Dev/telomere/AdamReplicates/telbams/twe/$i); do cd ~/Dev/telomere/AdamReplicates/telbams/twe/$i/$j; mkdir -p ~/Dev/telomere/AdamReplicates/output/twe/$i/$j; telbams=$(ls); telomerecat telbam2length -e -t 75 -v 2 --output ~/Dev/telomere/AdamReplicates/output/twe/$i/$j/telomerecat_length_75.csv $telbams; done; done

# Grab the results into summary csv files

for i in $(ls twe); do for j in $(ls twe/$i); do for k in $(ls twe/$i/$j); do cat twe/$i/$j/$k >> $i.csv; done; done; done

# Attach age data grabbed from Gemini (remove duplicates and sort by sample name)











