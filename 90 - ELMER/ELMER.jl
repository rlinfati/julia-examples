using Pkg
Pkg.activate(".")
Pkg.instantiate()

using HTTP
using JSON
using DataFrames
using XLSX

XLSX.openxlsx("elmer1.xlsx", mode="w") do xf
    r_ffmm = HTTP.get("http://www.elmercurio.com/inversiones/json/jsonTablaRankingFFMM.aspx")
    s_ffmm = String(r_ffmm.body)
    j_ffmm = JSON.parse(s_ffmm)
    df_ffmm = vcat(DataFrame.(j_ffmm["rows"])...)
    
    df_ffmm_cols = [:Categ, :VarParIndUmes, :VarParIndU3meses, :VarParInstUmes, :VarParInstU3meses]
    df_ffmm1 = df_ffmm[!, df_ffmm_cols]
    
    sxf = XLSX.addsheet!(xf, "Resumen Par")
    XLSX.writetable!(sxf, collect(DataFrames.eachcol(df_ffmm1)), DataFrames.names(df_ffmm1) ) 
        
    df_ffmm_cols = [:Categ, :RtbUltMes, :RtbUlt3Meses, :RtbUltAnio, :RtbUlt5anios]
    df_ffmm1 = df_ffmm[!, df_ffmm_cols]
    
    sxf = XLSX.addsheet!(xf, "Resumen Rt")
    XLSX.writetable!(sxf, collect(DataFrames.eachcol(df_ffmm1)), DataFrames.names(df_ffmm1) ) 

    the_ffmm_categ = [8, 11, 12, 13]

    df_run = []
    push!(df_run , "8377-L", "9067-L", "9043-L", "8448-L" ,"8555-L", "9041-M", "8525-M", "9042-M")
    push!(df_run , "8638-CLASI", "8639-CLASI", "8640-CLASI", "9063-INVER", "9062-INVER", "9060-INVER")
    push!(df_run , "8994-F1", "10020-F1", "8992-F1", "10021-F1", "10063-F1", "8993-F1", "10064-F1")
    push!(df_run , "8088-M", "8710-CLASI")
    push!(df_run , "8054-M", "8625-CLASI")
    push!(df_run , "9569-A", "9570-A")

    df_cols = [Symbol("Rentb1 mes"), :Rentb3m, :RentbY, :Rentb12m]
    push!(df_cols , :varpar1m, :varpar1Y, :FondoFull, :adm, :TAC, :Fondo)

    the_ffmm = DataFrame()
    for r in j_ffmm["rows"]
        if r["Id"] ∉ string.(the_ffmm_categ) continue end
        @show (r["Id"], r["Categ"])
        r_ffmms = HTTP.get("http://www.elmercurio.com/inversiones/json/jsonTablaFull.aspx?idcategoria=" * r["Id"])
        j_ffmms = JSON.parse(String(r_ffmms.body))
        df = vcat(DataFrame.(j_ffmms["rows"])...)
        the_ffmm = vcat(the_ffmm, df)
    end

    df_rows = [v in df_run for v in the_ffmm[!, :FondoFull]]
    df2 = the_ffmm[ df_rows, df_cols]

    sxf = XLSX.addsheet!(xf, "Balanceados - RL")
    XLSX.writetable!(sxf, collect(DataFrames.eachcol(df2)), DataFrames.names(df2) ) 

    ffmmadms = unique(the_ffmm[!, :adm])
    for ffmmadm in ffmmadms
        df_rows = [v == ffmmadm for v in the_ffmm[!, :adm]]
        df2 = the_ffmm[df_rows, df_cols]

        sxf = XLSX.addsheet!(xf, "B-" * ffmmadm)
        XLSX.writetable!(sxf, collect(DataFrames.eachcol(df2)), DataFrames.names(df2) ) 
    end
end

XLSX.openxlsx("elmer2.xlsx", mode="w") do xf
    r_ffmm = HTTP.get("http://www.elmercurio.com/inversiones/json/jsonTablaRankingFFMM.aspx")
    s_ffmm = String(r_ffmm.body)
    j_ffmm = JSON.parse(s_ffmm)
    df_ffmm = vcat(DataFrame.(j_ffmm["rows"])...)
    
    sxf = XLSX.addsheet!(xf, "ID-0")
    XLSX.writetable!(sxf, collect(DataFrames.eachcol(df_ffmm)), DataFrames.names(df_ffmm) ) 

    for r in eachrow(df_ffmm)
        @show r[:Id], r[:Categ]
        r_ffmms = HTTP.get("http://www.elmercurio.com/inversiones/json/jsonTablaFull.aspx?idcategoria=" * r[:Id])
        j_ffmms = JSON.parse(String(r_ffmms.body))
        df = vcat(DataFrame.(j_ffmms["rows"])...)

        sxf = XLSX.addsheet!(xf, "ID-" * r[:Id])
        XLSX.writetable!(sxf, collect(DataFrames.eachcol(df)), DataFrames.names(df) ) 
    end
end
