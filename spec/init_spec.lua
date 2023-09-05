describe("Test the requires", function()
	package.loaded["awful"] = {}
	package.loaded["awful.spawn"] = {}
	package.loaded["gears.timer"] = {}
    it("init", function()
        require("init")
    end)
    it("layout", function()
        require("layout")
    end)
    it("util", function()
        require("util")
    end)
    it("widget", function()
        require("widget")
    end)
end)
