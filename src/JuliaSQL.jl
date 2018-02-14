__precompile__()

module JuliaSQL

    #includes
    include("io.jl")
    include("structs.jl")

    function connect(con_url::String)
        driver_name, con_info = split(con_url, "://")[1], nothing
        if io.driver_support(driver_name)
            if io.driver_class(driver_name) == "mysql-family"
                #url = "mysql://$uid:$psswd@$host:$port/$schema_name?$args"
                url_splits = split(replace(con_url, "$driver_name://", ""), "/") ; user_info, host_info = split(url_splits[1], "@")
                uid, psswd = split(user_info, ":")
                host, port = split(host_info, ":")
                schema_name, args = split(url_splits[2], "?")[1], split(url_splits[2], "?")[2]
                con_info = Dict(
                    "driver" => io.driver_class(driver_name),
                    "uid" => uid,
                    "psswd" => psswd,
                    "host" => host,
                    "port" => port,
                    "schema" => schema_name,
                    "args" => args != "" ? string("&", args) : args
                )
            elseif io.driver_class(driver_name) == "sqlite-family"
                con_info = Dict(
                    "driver" => io.driver_class(driver_name),
                    "schema" => con_url[length(driver_name) + 4:end],
                    "args" => ""
                )
            end

            result = structs.con(Dict("driver" => con_info["driver"], "url" => io.create_jdbc_url(con_info), "args" => con_info["args"]))
        else
            print("$driver_name is unsupported driver")
            result = false
        end

        return result
    end

end
