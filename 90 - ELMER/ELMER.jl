using Pkg
Pkg.activate(".")
Pkg.instantiate()

using HTTP
using JSON
using DataFrames
using XLSX

XLSX.openxlsx("elmer1.xlsx", mode = "w") do xf
    r_ffmm = HTTP.get("http://www.elmercurio.com/inversiones/json/jsonTablaRankingFFMM.aspx")
    s_ffmm = String(r_ffmm.body)
    j_ffmm = JSON.parse(s_ffmm)
    df_ffmm = vcat(DataFrame.(j_ffmm["rows"])...)

    df_ffmm_cols = [:Categ, :VarParIndUmes, :InvNetaUmes, :VarParIndU3meses, :InvNetaU3meses, :Patrimonio]
    df_ffmm1 = df_ffmm[!, df_ffmm_cols]

    sxf = XLSX.addsheet!(xf, "Resumen Par")
    XLSX.writetable!(sxf, collect(DataFrames.eachcol(df_ffmm1)), DataFrames.names(df_ffmm1))

    df_ffmm_cols = [:Categ, :RtbUltMes, :RtbUlt3Meses, :RtbUltAnio, :RtbUlt5anios]
    df_ffmm1 = df_ffmm[!, df_ffmm_cols]

    sxf = XLSX.addsheet!(xf, "Resumen Rt")
    XLSX.writetable!(sxf, collect(DataFrames.eachcol(df_ffmm1)), DataFrames.names(df_ffmm1))

    the_ffmm_categ = [8, 9, 11, 12, 13]

    df_run = []
    push!(df_run, "9570-A", "9569-A", "9568-A") # FINTUAL
    push!(df_run, "8088-M", "8054-M") # BANCHILE
    push!(df_run, "9042-M", "8525-M", "9041-M") # BANCHILE ESTRATEGICO
    push!(df_run, "8555-L", "8448-L", "9043-L", "9067-L", "8377-L") # BANCHILE PORTAFOLIO ACTIVO
    push!(df_run, "8710-CLASI", "8625-CLASI") # BCI
    push!(df_run, "9060-INVER", "9062-INVER", "9063-INVER") # BCI CARTERA PATRIMONIAL
    push!(df_run, "8640-CLASI", "8639-CLASI", "8638-CLASI") # BCI CARTERA DINAMICA
    push!(df_run, "8971-F1", "9931-F1", "9922-F1", "9987-F1") # ITAU
    push!(df_run, "8993-F1", "8992-F1", "8994-F1") # ITAU GESTIONADO
    push!(df_run, "10064-F1", "10063-F1", "10021-F1", "10020-F1") # ITAU CARTERA    

    df_cols = [Symbol("Rentb1 mes"), :Rentb3m, :RentbY, :Rentb12m]
    push!(df_cols, :FondoFull, :adm, :TAC, :Fondo)
    push!(df_cols, :invNet1m, :invNet1y, :varpar1m, :varpar1Y, :patrim, :par)

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
    df2 = the_ffmm[df_rows, df_cols]

    sxf = XLSX.addsheet!(xf, "FFMM - RL")
    XLSX.writetable!(sxf, collect(DataFrames.eachcol(df2)), DataFrames.names(df2))

    ffmmadms = unique(the_ffmm[!, :adm])
    for ffmmadm in ffmmadms
        df_rows = [v == ffmmadm for v in the_ffmm[!, :adm]]
        df2 = the_ffmm[df_rows, df_cols]

        sxf = XLSX.addsheet!(xf, ffmmadm)
        XLSX.writetable!(sxf, collect(DataFrames.eachcol(df2)), DataFrames.names(df2))
    end
end

XLSX.openxlsx("elmer2.xlsx", mode = "w") do xf
    r_ffmm = HTTP.get("http://www.elmercurio.com/inversiones/json/jsonTablaRankingFFMM.aspx")
    s_ffmm = String(r_ffmm.body)
    j_ffmm = JSON.parse(s_ffmm)
    df_ffmm = vcat(DataFrame.(j_ffmm["rows"])...)

    sxf = XLSX.addsheet!(xf, "ID-0")
    XLSX.writetable!(sxf, collect(DataFrames.eachcol(df_ffmm)), DataFrames.names(df_ffmm))

    the_ffmm = DataFrame()
    for r in eachrow(df_ffmm)
        @show r[:Id], r[:Categ]
        r_ffmms = HTTP.get("http://www.elmercurio.com/inversiones/json/jsonTablaFull.aspx?idcategoria=" * r[:Id])
        j_ffmms = JSON.parse(String(r_ffmms.body))
        df = vcat(DataFrame.(j_ffmms["rows"])...)
        the_ffmm = vcat(the_ffmm, df)

        sxf = XLSX.addsheet!(xf, "ID-" * r[:Id])
        XLSX.writetable!(sxf, collect(DataFrames.eachcol(df)), DataFrames.names(df))
    end

    ffmmadms = unique(the_ffmm[!, :adm])
    for ffmmadm in ffmmadms
        @show ffmmadm
        df_rows = [v == ffmmadm for v in the_ffmm[!, :adm]]
        df2 = the_ffmm[df_rows, :]

        sxf = XLSX.addsheet!(xf, "AGP-" * ffmmadm)
        XLSX.writetable!(sxf, collect(DataFrames.eachcol(df2)), DataFrames.names(df2))
    end

end
