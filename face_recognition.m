function best = face_recognition( img, KPP )
% identification dans la base de connaissance des plus proches images (KPP)
% de l'image � identifier (img)

if(nargin < 2)
    KPP = 3;
end
if(nargin < 3)
    visu = true;
end

%% lecture des param�tres globaux
load('params.mat'); % params est une structure (cf. face_learning)

%% CUT HERE ====================================================================
N_AC_PATTERNS = params.N_AC_PATTERNS;

%% CUT HERE ====================================================================

%% extraction des blocs DCT
%% CUT HERE ====================================================================
%% CUT HERE ====================================================================

%% Normalisation et quantification
%% CUT HERE ====================================================================
%% CUT HERE ====================================================================

%% Comptage des occurrences des motifs globaux
load('G_Patterns.mat');
AC_Signatures = zeros(N_AC_PATTERNS,1);
load('QAC')

for idx = 1:N_AC_PATTERNS
    AC_Signatures(idx) = sum(ismember(G_Patterns(idx,:),QAC));
end

%% S�lection des KPP meilleures AC_Patterns_Histo par PVH
best = ones(KPP+1,3)*-1; % chaque ligne est <SAD,N�individu,N�profil>
%% CUT HERE ====================================================================

%% CUT HERE ====================================================================
best = best(1:(end-1),2:end);

%% visualisation des visages possiblement identifi�s
if( visu)
    figure;
    subplot(1,KPP+1,1);
    imshow(img);
    for b = 1:KPP
        subplot(1,KPP+1,b+1);
        filename = sprintf('%s/s%d/%d.png',params.DIR,max(b,1),max(b,2));
        imreco = imread(filename);
        imshow(imreco);
    end
end
end

