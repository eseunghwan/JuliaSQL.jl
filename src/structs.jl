module structs

    include("io.jl")

    #using Logging
    #Logging.configure(level = Logging.CRITICAL)
    using JDBC, JavaCall, DataFrames

    #init JDBC
    for driver_family in io.driver_families()
        JavaCall.addClassPath(joinpath(dirname(@__FILE__), "drivers", "$driver_family.jar"))
    end
    JDBC.init()

    mutable struct con
        #values
        result::Dict

        #hidden values
        _driver::Any
        _status::String
        _con::Any
        _cursor::Any
        _con_info::Dict

        #functions
        execute::Function
        close::Function

        function con(con_info)
            instance = new(con_info)

            #set con object
            instance._driver = con_info["driver"] ; con_info = delete!(con_info, "driver")
            try
                instance._con = JDBC.DriverManager.getConnection(con_info["url"]) ; con_info = delete!(con_info, "url")
                instance._cursor = JDBC.createStatement(instance._con)
                instance._status = "success"
                instance._con_info = con_info
            catch error
                instance._con = nothing
                instance._status = "failed"
                instance._con_info = ""
            end

            instance.execute = function(query)
                datas, columns, result = [], [], []
                column_set = false

                rs = JDBC.executeQuery(instance._cursor, query)
                for row in JDBC.JDBCRowIterator(rs)
                    append!(datas, [[Any(item) for item in row]])
                end

                meta_data = JDBC.getTableMetaData(JDBC.executeQuery(instance._cursor, query))
                if !column_set
                    columns = [item[1] for item in meta_data]
                    column_set = true
                end

                for data in datas
                    item = Dict()
                    for idx in eachindex(columns)
                        item[columns[idx]] = data[idx]
                    end

                    append!(result, [item])
                end

                return result
            end

            instance.close = function()
                JDBC.close(instance._con)
            end

            return instance
        end
    end
    function Base.show(io::Base.IO, instance::con)
        args_string = join([join([sss for sss in split(ss, "=")], " = ") for ss in split(instance._con_info["args"], "&") if ss != ""], "\n")
        print(io, string(
            "driver : ", instance._driver, "\n",
            "status : ", instance._status,
            args_string != "" ? string("\n", args_string) : ""
        ))
    end
end