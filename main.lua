
PlayerPos = {}
PLUGIN = nil


function Initialize(Plugin)
	PLUGIN = Plugin
	Plugin:SetName("AntiX")
	Plugin:SetVersion(1)
	
	cPluginManager.AddHook(cPluginManager.HOOK_PLAYER_MOVING, OnPlayerMoving)
	cPluginManager.AddHook(cPluginManager.HOOK_PLAYER_SPAWNED, OnPlayerSpawned)
	cPluginManager.AddHook(cPluginManager.HOOK_PLAYER_BREAKING_BLOCK, OnPlayerBreakingBlock)
	
	LoadPlayers()
	return true
end

function LoadPlayers()
	cRoot:Get():ForEachPlayer(function(Player)
		local Pos = Vector3i(math.floor(Player:GetPosX()), math.floor(Player:GetPosY()), math.floor(Player:GetPosZ()))
		PlayerPos[Player:GetName()] = Pos
	end)
end

function OnPlayerBreakingBlock(Player, X, Y, Z, BlockFace, BlockType, BlockMeta)
	cRoot:Get():ForEachPlayer(function(Player)
		local World = Player:GetWorld()
		World:SendBlockTo(X + 1, Y, Z, Player)
		World:SendBlockTo(X - 1, Y, Z, Player)
		World:SendBlockTo(X, Y + 1, Z, Player)
		World:SendBlockTo(X, Y - 1, Z, Player)
		World:SendBlockTo(X, Y, Z + 1, Player)
		World:SendBlockTo(X, Y, Z - 1, Player)
	end)
end
		

function OnPlayerSpawned(Player)
	local Pos = Vector3i(math.floor(Player:GetPosX()), math.floor(Player:GetPosY()), math.floor(Player:GetPosZ()))
	PlayerPos[Player:GetName()] = Pos
	StreamPlayer(Player, Pos.x, Pos.y, Pos.z)
end

function OnPlayerMoving(Player)
	local PosX = math.floor(Player:GetPosX())
	local PosY = math.floor(Player:GetPosY())
	local PosZ = math.floor(Player:GetPosZ())
	
	local PlayerName = Player:GetName()
	
	local LastPos = PlayerPos[PlayerName]
	local CurrentPos = Vector3i(PosX, PosY, PosZ)
	if CurrentPos:Equals(LastPos) then
		PlayerPos[PlayerName]:Set(PosX, PosY, PosZ)
		return false
	end
	StreamPlayer(Player, PosX, PosY, PosZ)
end

function StreamPlayer(Player, PosX, PosY, PosZ)
	local World = Player:GetWorld()
	local ClientHandle = Player:GetClientHandle()
	for X = PosX - 10, PosX + 10 do
		for Y = PosY - 10, PosY + 10 do
			for Z = PosZ - 10, PosZ + 10 do
				local Block = World:GetBlock(X, Y, Z)
				if not cBlockInfo:IsTransparent(Block) then
					if not HasAir(World, X, Y, Z) then
						ClientHandle:SendBlockChange(X, Y, Z, E_BLOCK_IRON_ORE, 0)
					end
				end
			end
		end
	end
end

function HasAir(World, X, Y, Z)
	if (
		cBlockInfo:IsTransparent(World:GetBlock(X + 1, Y, Z)) or
		cBlockInfo:IsTransparent(World:GetBlock(X - 1, Y, Z)) or
		cBlockInfo:IsTransparent(World:GetBlock(X, Y + 1, Z)) or
		cBlockInfo:IsTransparent(World:GetBlock(X, Y - 1, Z)) or
		cBlockInfo:IsTransparent(World:GetBlock(X, Y, Z + 1))or
		cBlockInfo:IsTransparent(World:GetBlock(X, Y, Z - 1))) then
		return true
	end
	return false
end


