describe("Test helpers functions", function()
	package.loaded["awful"] = {}
	package.loaded["awful.spawn"] = {
        easy_async=function (cmd,f)
            f(cmd,0,0,1)
        end,
        easy_async_with_shell=function (cmd,f)
            f(cmd,0,0,1)
        end,
        with_line_callback=function (cmd,f)
            f.stdout(cmd)
        end

    }
    local timer ={
        start= function () end,
        connect_signal= function (t,f) end,
        emit_signal= function (t) end,
    }
    local timerMock=mock(timer,true)
    package.loaded["gears.timer"] =function() return timerMock end 


    it("file_exists", function()
        local helpers = require("helpers")
        assert.is_true(helpers.file_exists("init.lua"))
        assert.is_false(helpers.file_exists("init2.lua"))
    end)
    it("lines_from", function()
        local result = {
            "line1",
            "line2",
            "line3",
            "line4",
        }
        local helpers = require("helpers")
        assert.are.same(helpers.lines_from("spec/data/lines_from.txt"),result)
    end)
    it("lines_match", function()
        local result = {
            "line1",
            "line3",
        }
        local helpers = require("helpers")
        assert.are.same(helpers.lines_match("line[1,3]","spec/data/lines_from.txt"),result)
    end)
    it("first_line", function()
        local helpers = require("helpers")
        assert.are.same(helpers.first_line("spec/data/lines_from.txt"),"line1")
        assert.are.equals(helpers.first_line("spec/data/no_file.txt"),nil)
    end)
    it("first_nonempty_line", function()
        local helpers = require("helpers")
        assert.are.same(helpers.first_nonempty_line("spec/data/lines_from.txt"),"line1")
    end)


    it("newtimer", function()
        local helpers = require("helpers")

        assert.is_false(helpers.newtimer("name",10,"fun",false,false))
        assert.stub(timer.start).was.called_with(timerMock)
        assert.stub(timer.connect_signal).was.called_with(timerMock,"timeout", "fun")
        assert.stub(timer.emit_signal).was.called_with(timerMock,"timeout")
        assert.are.equals(helpers.newtimer("name",10,"fun",true,true),timerMock)
    end)

    it("async", function()
        local helpers = require("helpers")
        helpers.async("date",function (out,code)
            assert.is.truthy(#out)
            assert.is.truthy(code)
        end)
    end)
    it("async_with_shell", function()
        local helpers = require("helpers")
        helpers.async_with_shell("date",function (out,code)
            assert.is.truthy(#out)
            assert.is.truthy(code)
        end)
    end)
    it("line_callback", function()
        local helpers = require("helpers")
        helpers.line_callback("date",function (out)
            assert.is.truthy(#out)
        end)
    end)

    it("map_table", function()
        local helpers = require("helpers")
        helpers.set_map("key","value")
        assert.are.equals(helpers.get_map("key"),"value")
    end)

    it("element_in_table", function()
        local helpers = require("helpers")
        local table={
            a=1,
            b=2,
            c=3,
        }
        assert.is_true(helpers.element_in_table(1,table))
        assert.is_false(helpers.element_in_table(5,table))
    end)

    it("spairs", function()
        local helpers = require("helpers")
        local table={
            a=1,
            c=3,
            b=2,
        }
        local f=helpers.spairs(table)
        key,value=f()
        assert.are.equals(key,"a")
        assert.are.equals(value,1)
        key,value=f()
        assert.are.equals(key,"b")
        assert.are.equals(value,2)
        key,value=f()
        assert.are.equals(key,"c")
        assert.are.equals(value,3)
    end)

    it("trivial_partition_set", function()
        local helpers = require("helpers")
        local table={"a","b","c"}
        local result={{"a"}, {"b"}, {"c"}}
        assert.are.same(helpers.trivial_partition_set(table),result)
    end)

    it("powerset", function()
        local helpers = require("helpers")
        local table={"a","b","c"}
        local result={{},{"a"}, {"b"},{"b","a"}, {"c"},{"c","a"},{"c","b"},{"c","b","a"}}
        assert.are.same(helpers.powerset(table),result)
    end)
end)
