function face_learning
    %  Identifier les motifs globaux, G_Patterns, pr�sents dans toutes les
    %  images de tous les visages de la base de connaissance ainsi que les
    %  occurrences de ces motifs dans chaque image de chaque visage de la base.
    %  
    %  Chaque image est d�coup�e en N blocs 4x4. Chaque bloc est analys� en
    %  fr�quences via la DCT2 dont le coefficient DC est ignor�. Ensuite chaque
    %  image est r�pr�sent�e par une matrice Nx15 qui sert � la fois �
    %  identifier les motifs globaux et � construire l'histogramme de ces
    %  motifs pour chaque image de chaque visage de la base de connaissance.
    %
    % Les param�tres dont les motifs globaux, utiles � l'identification d'une
    % image inconnue sont enregistr�s dans le fichier 'params.mat' ainsi que
    % les histogrammes de chaque image de chaque visage de la base de
    % connaissance.
    %
    % Le m�me traitement peut �tre fait avec les coefficients DC. Mais ils sont
    % ignor�s pour ce projet.

    %% R�initialiser l'espace de travail
    clear
    clc

    %% D�finir le r�pertoire de la base de connaisssance #
    db_path = uigetdir();
    %% Initialiser les param�tres globaux
    BSZ = 4; %pour faire des blocs de 4x4
    QP = 6;%TODO: 22 ?
    N_AC_PATTERNS = 35;
    NB_FACES = 5;
    NB_IMAGES = 1; %TODO: d'autres valeurs
    DC_MEAN_ALL = 0;


    %% Extraire les N blocs DCT pour chaque image de chaque visage
    AC_list = cell(NB_FACES,NB_IMAGES);% les matrices Nx15
    dc_means = zeros(NB_FACES,NB_IMAGES);% les moyennes par image des DC
    % des constantes
    blocSz =  (1:BSZ) - 1;
    BZ2 = floor(BSZ/2);
    ACSZ = BSZ * BSZ - 1;   %TODO: le fameux 15 des matrices Nx15 ?
    
    % pour chaque visage
    for f = 1:NB_FACES
        face_path = sprintf('%s/s%d',db_path,f);

        % pour chaque image
        for fi = 1:NB_IMAGES
            fname = sprintf('%s/%d.png',face_path,fi);
            img = imread(fname);
            [h,w] = size(img);

            %faire des blocs de taille 4x4
            %DCT, AC_Mat = split(img,BSZ,BZ2, QP);
            DC = [];
            AC_Mat = cell(size(1:2:(h-3), 1), size(1:2:(w-3), 1));
            id = 1;
            for i= 1:2:(h-3)
                for j= 1:2:(w-3)
                    b = img(i:(i+3),j:(j+3));
                    tmp = round( dct2(b) * (DC_MEAN_ALL/ dc_means(f,fi)/QP));%TODO: vérifier
                    lol = reshape(tmp(:,:), 1, []);
                    AC_Mat(id) = {lol(2:size(lol,2))};
                    DC(id) = tmp(1,1);
                    id = id + 1;
                end
            end
            
            dc_means(f,fi) = mean(DC);
            DC_MEAN_ALL = mean2(dc_means);
            AC_list{f, fi} = AC_Mat;%TODO:nope, il faut garder les 15 les plus r�current si j'ai bien compris
        
        end
    end
    
   

    %% Stockage des param�tres dans une structure
    params = struct(...
        'BZS',BSZ,...
        'QP',QP,...
        'N_AC_PATTERNS',N_AC_PATTERNS,...
        'NB_FACES',NB_FACES,...
        'NB_IMAGES',NB_IMAGES,...
        'DC_MEAN_ALL',DC_MEAN_ALL,...
        'DIR',db_path);

    %% enregistrement de la structure dans un fichier
    save('params.mat','params');
    disp('dct done');

    %% Identification des motifs globaux, construction de leurs histogrammes
    G_Patterns = [];
    QAC = cell(NB_FACES, NB_IMAGES);
    for f = 1:NB_FACES
        for fi = 1:NB_IMAGES
            % normalisation et quantification des AC
            R(fi) = DC_MEAN_ALL / dc_means(fi);
            QAC(f,fi) = AC_Mat(f,fi) * R(fi) / QP;
    %% CUT HERE ====================================================================

            % identification des motifs et comptage de leurs occurrences.
                    % QAC est la matrice des vecteurs AC quantif�s
            for i = 1:size(QAC,1)
    %% CUT HERE ====================================================================
    %% CUT HERE ====================================================================
            end
        end
    end
    % Conserver les N_AC_PATTERNS motifs les plus pr�sents dans toutes les
    % images de tous les visages de la base.
    [~,Idx] = sort(G_Patterns(:,end),'descend');
    G_Patterns = G_Patterns(Idx(1:N_AC_PATTERNS),1:(end-1));

    % save G_Patterns
    save('G_Patterns.mat','G_Patterns')
    disp('G_Patterns done')

    %% Construction des histogrammes de toutes les images de chaque visage
    AC_Patterns_Histo = zeros(N_AC_PATTERNS,1);
    for f = 1:NB_FACES
        for fi = 1:NB_IMAGES
    %% CUT HERE ====================================================================
    %% CUT HERE ====================================================================
        end
    end
    disp('AC_Patterns_Histo done');


end


function DCT, AC_Mat = split(Matrix, N, pas, QP)
    AC_Mat = [];
    DCT = [];
    sizeN = N-1;
    for i = 1:pas:size(Matrix,1)-sizeN
        for j = 1:pas:size(Matrix,2)-sizeN
            tmp = dct2(Matrix(i:i+sizeN, j:j+sizeN)) /QP ;
            DCT(i,j) = tmp(1,1);
            AC_Mat{i,j} = reshape(tmp',1,[]);
        end
    end
end


