function AC_list = normalize(AC_list,DC_MEAN_ALL,dc_means, QP)


        R = DC_MEAN_ALL / dc_means;
        for i = 1:size(AC_list,1)
             AC_list(i, : ) = round( ( ( AC_list(i, :) * R) / QP) );
        end
            
end