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

N_AC_PATTERNS = params.N_AC_PATTERNS;

%% extraction des blocs DCT
ACSZ = params.BSZ * params.BSZ -1;
[AC_Mat,DC] = read_acdc_image(img,ACSZ);

%% Normalisation et quantification
dc_mean = mean(DC);
QAC = normalize(AC_Mat,params.DC_MEAN_ALL,dc_mean,params.QP);

%% Comptage des occurrences des motifs globaux
load('G_Patterns.mat');
AC_Signatures = zeros(N_AC_PATTERNS,1);


for idx = 1:N_AC_PATTERNS
    AC_Signatures(idx) = sum(ismember(G_Patterns(idx,:),QAC));
end

load('AC_Patterns_Histo')

%% Sélection des KPP meilleures AC_Patterns_Histo par PVH
best = ones(KPP+1,3)*-1; % chaque ligne est <SAD,N°individu,N°profil>
%% CUT HERE ====================================================================
id = 1;
for i = size(AC_Patterns_Histo,1)
    for j = size(size(AC_Patterns_Histo,2))
        best(id) = [sum(AC_Patterns_Histo - AC_Patterns),
        
    end
end
    
%% CUT HERE ====================================================================
best = best(1:(end-1),2:end);

%% visualisation des visages possiblement identifiés
if( visu)
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

