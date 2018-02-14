module io

    #supported drivers
    __drivers__ = [
        "mysql",
        "mariadb",
        "sqlite"
    ]

    function driver_support(driver_name)
        return driver_name in __drivers__
    end

    function driver_families()
        result = []
        for driver_name in __drivers__
            append!(result, [driver_class(driver_name)])
        end

        return unique(result)
    end

    function driver_class(driver_name)
        result = nothing
        if driver_name in ["mysql", "mariadb"]
            result = "mysql-family"
        elseif driver_name in ["sqlite"]
            result = "sqlite-family"
        end

        return result
    end

    function create_jdbc_url(con_info::Dict)
        jdbc_url = nothing
        if con_info["driver"] == "mysql-family"
            jdbc_url = string("jdbc:mysql://", con_info["host"], ":", con_info["port"], "/", con_info["schema"], "?user=", con_info["uid"], "&password=", con_info["psswd"], con_info["args"])
        elseif con_info["driver"] == "sqlite-family"
            jdbc_url = string("jdbc:sqlite:", con_info["schema"])
        end

        return jdbc_url
    end
    
end