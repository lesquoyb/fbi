function best = face_recognition( img, KPP )
% identification dans la base de connaissance des plus proches images (KPP)
% de l'image à identifier (img)
if(nargin < 2)
    KPP = 3;
end
if(nargin < 3)
    visu = true;
end

%% lecture des paramètres globaux
load('params.mat'); % params est une structure (cf. face_learning)
 BZS = params.BSZ;
 QP = params.QP;
 N_AC_PATTERNS = params.N_AC_PATTERNS;
 NB_FACES = params.NB_FACES;
 NB_IMAGES = params.NB_IMAGES;
 DC_MEAN_ALL = params.DC_MEAN_ALL;
 DIR = params.DIR;
%% extraction des blocs DCT

N_AC_PATTERNS = params.N_AC_PATTERNS;

%% extraction des blocs DCT
ACSZ = params.BSZ * params.BSZ -1;
[AC_Mat,DC] = read_acdc_image(img,ACSZ);
 
%% Normalisation et quantification
QAC = normalize(AC_Mat,params.DC_MEAN_ALL,mean(DC),params.QP);

%% Comptage des occurrences des motifs globaux
load('G_Patterns.mat');
AC_Signatures = zeros(N_AC_PATTERNS,1);


for idx = 1:N_AC_PATTERNS
    s = 0;
    for i = 1:size(QAC,1)
        if(G_Patterns(idx, : ) == QAC(i,:))  
            s = s + 1;
        end
    end
    AC_Signatures(idx) = s;
end

load('AC_Patterns_Histo')

%% Sélection des KPP meilleures AC_Patterns_Histo par PVH
best = ones(KPP+1,3)*-1; % chaque ligne est <SAD,N°individu,N°profil>
sad = ones(NB_FACES,NB_IMAGES);
for f = 1:NB_FACES
    for fi = 1:NB_IMAGES
        s = 0;
        for i = 1:N_AC_PATTERNS
            s = s + abs(AC_Patterns_Histo(f,fi,i) - AC_Signatures(i)) ;
        end
        sad(f,fi) = s;
    end
end


for i = 1:KPP
    min = sad(1,1);
    idx = 1;
    idy = 1;
    for f = 1:NB_FACES
        for fi = 1:NB_IMAGES
            if(sad(f,fi) < min)
                min = sad(f,fi);
                idy = f;
                idx = fi;
            end
        end
    end
    
    best(i, 1) = min;
    best(i, 2) = idy;
    best(i, 3) = idx;
    sad(idx,  idy) = intmax;

end
    
best = best(1:(end-1),2:end);

%% visualisation des visages possiblement identifiés
if(visu)
    figure;
    subplot(1,KPP+1,1);
    imshow(img);
    for b = 1:KPP
        subplot(1,KPP+1,b+1);
        filename = sprintf('%s/s%d/%d.png',params.DIR,best(b,1),best(b,2));
        imreco = imread(filename);
        imshow(imreco);
    end
end
end

