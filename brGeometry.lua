---@type _,br,_
local  _,br,_ = ...

---@type br.Logging, br.Settings
local Log,Settings = br.Logging,br.Settings

---@class br.Geometry
---@field Distance2D fun(self: br.Geometry, x1: number, y1: number, x2: number, y2: number): number @Calculates the 2D distance between two points
---@field Distance3D fun(self: br.Geometry, x1: number, y1: number, z1: number, x2: number, y2: number, z2: number): number @Calculates the 3D distance between two points
---@field GetFacing fun(self: br.Geometry, Unit1: Unit, Unit2?: string|number, Degrees?: number): boolean @Determines if Unit1 is facing Unit2 within a certain degree
local Geometry = br.Geometry or {}


function Geometry:Distance2D(x1,y1,x2,y2)
    local dx = x2 - x1
    local dy = y2 - y1
    return math.sqrt(dx * dx + dy * dy)
end
function Geometry:Distance3D(x1,y1,z1,x2,y2,z2)
    local dx = x2 - x1
    local dy = y2 - y1
    local dz = z2 - z1
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

function Geometry:GetFacing(Unit1,Unit2,Degrees)
    if Degrees == nil then
		Degrees = 90
	end
	if Unit2 == nil then
		Unit2 = br.ActivePlayer
	end
	if br.ObjectExists(Unit1.guid) and 
        br.ObjectExists(Unit2.guid) then
            
		local angle3
		local angle1 = br.ObjectFacing(Unit1.guid)
		local angle2 = br.ObjectFacing(Unit2.guid)
		local Y1, X1, Z1 = br.ObjectLocation(Unit1.guid)
		local Y2, X2, Z2 = br.ObjectLocation(Unit2.guid)
		if Y1 and X1 and Z1 and angle1 and Y2 and X2 and Z2 and angle2 then
			local deltaY = Y2 - Y1
			local deltaX = X2 - X1
			angle1 = math.deg(math.abs(angle1 - math.pi * 2))
			if deltaX > 0 then
				angle2 = math.deg(math.atan(deltaY / deltaX) + (math.pi / 2) + math.pi)
			elseif deltaX < 0 then
				angle2 = math.deg(math.atan(deltaY / deltaX) + (math.pi / 2))
			end
			if angle2 - angle1 > 180 then
				angle3 = math.abs(angle2 - angle1 - 360)
			elseif angle1 - angle2 > 180 then
				angle3 = math.abs(angle1 - angle2 - 360)
			else
				angle3 = math.abs(angle2 - angle1)
			end
			-- return angle3
			if angle3 < Degrees then
				return true
			else
				return false
			end
        else
            Log:Log("Geometry:GetFacing - Unable to retrieve location or facing for one or both units.")
            return false
		end
    else
        Log:Log("Geometry:GetFacing - One or both units do not exist or are not visible.")
        return false
	end
end

function Geometry:GetAnglesBetweenObjects(Unit1,Unit2)
	if Unit1 and br.ObjectExists(Unit1.guid) and Unit2 and br.ObjectExists(Unit2.guid) then

		if br.unlocker == "DMC" then
			return br.GetAngleBetweenPositions(Unit1.guid, Unit2.guid)
		end


		local X1, Y1, Z1 = br.ObjectLocation(Unit1.guid)
		local X2, Y2, Z2 = br.ObjectLocation(Unit2.guid)
		return math.atan2(Y2 - Y1, X2 - X1) % (math.pi * 2),
			math.atan((Z1 - Z2) / math.sqrt(math.pow(X1 - X2, 2) + math.pow(Y1 - Y2, 2))) % math.pi
	else
		return 0, 0
	end
end

