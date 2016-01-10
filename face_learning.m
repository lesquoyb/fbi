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
    QP = 22;
    N_AC_PATTERNS = 35;
    NB_FACES = 20;
    NB_IMAGES = 5; 
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
            id = 1;
            AC_Mat = zeros(size(1:2:(h-3),2)*size(1:2:(w-3),2), ACSZ);
            DC = zeros(1, size(1:2:(h-3),2)*size(1:2:(w-3),2));
            for i= 1:2:(h-3)
                for j= 1:2:(w-3)
                    b = img(i:(i+3),j:(j+3));
                    tmp = reshape(dct2(b)', 1, []);
                    AC_Mat(id, :) = tmp(2:size(tmp,2));
                    DC(id) = tmp(1);
                    id = id + 1;
                end
            end
            AC_list{f, fi} = AC_Mat;
            dc_means(f,fi) = mean(DC);     
        end
    end
    DC_MEAN_ALL = mean2(dc_means);
   

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
    for f = 1:NB_FACES
        for fi = 1:NB_IMAGES
            % normalisation et quantification des AC
            R = DC_MEAN_ALL / dc_means(fi);
            for i = 1:size( AC_list{f, fi},1)
                 AC_list{f, fi}(i, : ) = round( ( ( AC_list{f, fi}(i, :) * R) / QP) );
            end
            G_Patterns = zeros(size( AC_list{f, fi},1),size( AC_list{f, fi},2)+1);

            
            % identification des motifs et comptage de leurs occurrences.
            % QAC est la matrice des vecteurs AC quantif�s
            last = 1;
            for i = 1:size( AC_list{f, fi},1) 
                found = false;
                for j = 1:size(G_Patterns,1)
                    if( G_Patterns(j, 1:end-1 ) ==  AC_list{f, fi}(i, :))
                        found = true;
                        break;
                    end
                end
                
                if(found == false)
                    G_Patterns(last, :) = [AC_list{f, fi}(i, :),1  ];
                    last = last +1;
                else
                   G_Patterns(j,end) = G_Patterns(j,end)+1;
                end
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
    AC_Patterns_Histo = zeros(size(G_Patterns,1),1);
    for f = 1:NB_FACES
        for fi = 1:NB_IMAGES
            MAC = cell2mat(AC_list(f,fi));
            seen = zeros(size(MAC,1),1);
            for i = 1:size(G_Patterns,2)
                for j = 1:size(MAC,1)
                    if(seen(j) == 0)
                       if( MAC(j, :) == G_Patterns(i, :)) 
                            AC_Patterns_Histo(i) = AC_Patterns_Histo(i) + 1;
                            seen(j) = 1;
                        end
                    end
                end
            end
        end
    end
    save('AC_Patterns_Histo.mat','AC_Patterns_Histo');
    disp('AC_Patterns_Histo done');


end
