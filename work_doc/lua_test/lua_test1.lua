
    template <typename ...Args>
    void call(std::string const &name, std::function<void(lua_State *)> callback, Args &&...args)
    {
        lua_pushcfunction(state_, stack_trace);
        lua_getglobal(state_, name.c_str());
        if (!lua_isfunction(state_, -1)) {
            RAIN_ERROR("Invalid function <" + name + ">.");
            lua_pop(state_, 2);
            return;
        }

        (void)std::initializer_list<int>{push_type(std::forward<Args>(args))...};

        auto n = sizeof...(args);
        if (lua_pcall(state_, n, LUA_MULTRET, -n-2)) {
            std::string err = lua_tostring(state_, -1);
            RAIN_ERROR("Call function <" + name + "> failed: " + err);
            lua_pop(state_, lua_gettop(state_));
            return;
        }

        if (callback)
            callback(state_);

        lua_pop(state_, lua_gettop(state_));
    }

    int push_type(bool b)
    {
        lua_pushboolean(state_, b);
        return 0;
    }

    int push_type(int n)
    {
        lua_pushinteger(state_, n);
        return 0;
    }

    int push_type(double d)
    {
        lua_pushnumber(state_, d);
        return 0;
    }

    int push_type(const char *str)
    {
        lua_pushstring(state_, str);
        return 0;
    }

    int push_type(std::string const &str)
    {
        lua_pushstring(state_, str.c_str());
        return 0;
    }

    static int stack_trace(lua_State *L)
    {
        lua_Debug dbg;
        auto depth = 10;
        std::stringstream ss;
        std::string err = lua_tostring(L, -1);

        ss << "\nStack Trace:\n|- " << err << '\n';

        for (auto i = 0; lua_getstack(L, 2 + i, &dbg) != 0 && i < depth; i++) {
            lua_getinfo(L, "Sln", &dbg);
            ss << std::string((i+1) * 2u, ' ') << "|- Invoked by " << dbg.short_src;
            ss << '(' << dbg.currentline << "): " << dbg.name << '\n';
        }

        lua_pop(L, 1);
        lua_pushstring(L, ss.str().c_str());
        return 1;
  }