-- ============================================================
-- Shapes GUI — curated COBALT patterns, per-shape settings, reset
-- LocalScript. No anchoring anywhere. Rotation is preserved per-block.
-- ============================================================
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LPlayer = Players.LocalPlayer

local LPlate, ActiveParts
for _, v in pairs(workspace.Plates:GetChildren()) do
	if v:FindFirstChild("Owner") and v.Owner.Value == LPlayer then
		LPlate = v:FindFirstChild("Plate")
		ActiveParts = v:FindFirstChild("ActiveParts")
		break
	end
end
if not LPlate then warn("[Shapes] No plate") return end

-- ============ SHAPES REGISTRY (forward-declared so assignLayers can see it) ============
local SHAPES = {}
local SHAPE_ORDER = {}

-- ============ UNIVERSAL CONFIG ============
local CFG = {
	size = 1.0,
	speed = 1.0,
	height = 0,
	direction = 1,
}
local CFG_DEFAULTS = { size = 1.0, speed = 1.0, height = 0, direction = 1 }

local SPACING = 6
local ORBIT_RADIUS = 14
local ORBIT_SPEED = 1.5

local currentShape = "Ring"
local ActiveBlocks = {}
local holding = false
local lastBlockCount = 0

-- ============ LAYER ASSIGNMENT ============
local function assignLayers()
	local activeCount = #ActiveBlocks
	if activeCount == 0 then return end

	local ringCfg = (SHAPES.Ring and SHAPES.Ring.settings) or {}
	local spacing = math.max(2, ringCfg.layerGap or SPACING)
	local tilt = ringCfg.layerTilt or 0.65

	local cursor = 1
	local layerIndex = 0
	local layerDefs = {}

	while cursor <= activeCount do
		local layerRadius = math.max(ORBIT_RADIUS, spacing * 1.35) + layerIndex * spacing
		local capacity = math.max(3, math.floor((2 * math.pi * layerRadius) / spacing))
		local layerCount = math.min(capacity, activeCount - cursor + 1)
		table.insert(layerDefs, { first = cursor, count = layerCount, radius = layerRadius })
		cursor += layerCount
		layerIndex += 1
	end

	for defIdx, def in ipairs(layerDefs) do
		local actualLayerIndex = defIdx - 1
		local verticalDirection = actualLayerIndex % 2 == 1 and 1 or -1
		local verticalBand = actualLayerIndex == 0 and 0 or math.ceil(actualLayerIndex / 2)
		local yOffset = verticalDirection * verticalBand * math.min(spacing * tilt, 12)

		for slot = 1, def.count do
			local data = ActiveBlocks[def.first + slot - 1]
			data.layerIndex = actualLayerIndex
			data.layerSlot = slot
			data.layerCount = def.count
			data.layerRadius = def.radius
			data.layerYOffset = yOffset
		end
	end
end

-- ============ PATTERN HELPERS ============
local function ratio(i, n)
	return n <= 1 and 0.5 or (i - 1) / (n - 1)
end

local function baseR(n, r, s)
	return math.max(r, s * math.sqrt(n) * 0.62)
end

local function cfgVal(cfg, key, default)
	if cfg and cfg[key] ~= nil then return cfg[key] end
	return default
end

-- ============ PATTERNS ============

local function ringPattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local radius = (entry and entry.layerRadius) or r
	local yOff = (entry and entry.layerYOffset) or 0
	return Vector3.new(math.cos(slotAngle) * radius, 2.5 + yOff, math.sin(slotAngle) * radius)
end

local function tornadoPattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local twist = cfgVal(cfg, "twist", 16)
	local heightSpan = cfgVal(cfg, "heightSpan", 22)
	local q = ratio(i, n)
	local angle = (i - 1) * math.pi * 2 / math.max(n, 1) + t * d
	local rr = r * (0.25 + q * 1.25)
	return Vector3.new(math.cos(angle + q * twist) * rr, -7 + q * heightSpan, math.sin(angle + q * twist) * rr)
end

local function linePattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local spacing = cfgVal(cfg, "spacing", 1)
	local zOff = cfgVal(cfg, "zOffset", -8)
	return Vector3.new((i - (n + 1) * 0.5) * s * spacing, 3, zOff)
end

local function wallPattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local colFactor = cfgVal(cfg, "columnFactor", 1.6)
	local zOff = cfgVal(cfg, "zOffset", -8)
	local cols = math.max(1, math.ceil(math.sqrt(n * colFactor)))
	local row = math.floor((i - 1) / cols)
	local col = (i - 1) % cols
	return Vector3.new((col - (cols - 1) * 0.5) * s, 7 - row * vs, zOff)
end

local function spiralWallPattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local amplitude = cfgVal(cfg, "amplitude", 2)
	local colFactor = cfgVal(cfg, "columnFactor", 1.6)
	local cols = math.max(1, math.ceil(math.sqrt(n * colFactor)))
	local row = math.floor((i - 1) / cols)
	local col = (i - 1) % cols
	return Vector3.new((col - (cols - 1) * 0.5) * s, 7 - row * vs, -8 + math.sin(t * 2 + col) * amplitude)
end

local function infinityPattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local radiusScale = cfgVal(cfg, "radiusScale", 1)
	local crossingHeight = cfgVal(cfg, "crossingHeight", 0.35)
	local angle = (i - 1) * math.pi * 2 / math.max(n, 1) + t * d
	local denom = 1 + math.sin(angle) ^ 2
	local rr = r * radiusScale
	local crossing = math.sin(angle * 2) * s * crossingHeight
	return Vector3.new(rr * math.cos(angle) / denom, 3 + crossing, rr * math.sin(angle) * math.cos(angle) / denom)
end

local function wavePattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local amplitude = cfgVal(cfg, "amplitude", 3)
	local frequency = cfgVal(cfg, "frequency", 1)
	local q = ratio(i, n)
	return Vector3.new((q - 0.5) * r * 3, 3 + math.sin(t * 3 * frequency + q * 12) * amplitude, -8)
end

local function spherePattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local noise = cfgVal(cfg, "noise", 0)
	local y = 1 - 2 * ((i - 0.5) / n)
	local radial = math.sqrt(math.max(0, 1 - y * y))
	local angle = i * 2.399963 + t
	local rr = baseR(n, r, s)
	if noise > 0 then
		rr = rr * (1 + (((math.sin(i * 91.73) * 43758.5453) % 1) - 0.5) * noise)
	end
	return Vector3.new(math.cos(angle) * radial * rr, y * rr + 3, math.sin(angle) * radial * rr)
end

local function sinkingPattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local sinkDepth = cfgVal(cfg, "sinkDepth", 7)
	local angle = (i - 1) * math.pi * 2 / math.max(n, 1) + t * d
	return Vector3.new(math.cos(angle) * r, 5 - (t % 4) / 4 * sinkDepth, math.sin(angle) * r)
end

local function helixPattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local turns = cfgVal(cfg, "turns", 4)
	local heightSpan = cfgVal(cfg, "heightSpan", 20)
	local q = ratio(i, n)
	return Vector3.new(math.cos(q * math.pi * turns * 2 + t * d) * r, -7 + q * heightSpan, math.sin(q * math.pi * turns * 2 + t * d) * r)
end

local function crownPattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local points = cfgVal(cfg, "points", 7)
	local spikeHeight = cfgVal(cfg, "spikeHeight", 7)
	local angle = (i - 1) * math.pi * 2 / math.max(n, 1) + t * d
	local spike = math.max(0, math.cos(angle * points)) ^ 5
	return Vector3.new(math.cos(angle) * r, 3 + spike * spikeHeight, math.sin(angle) * r)
end

local function haloPattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local tilt = cfgVal(cfg, "tilt", 0.22)
	local angle = (i - 1) * math.pi * 2 / math.max(n, 1) + t * d
	local p = Vector3.new(math.cos(angle) * r, 0, math.sin(angle) * r)
	return CFrame.Angles(tilt * 0.8, 0, -tilt):VectorToWorldSpace(p) + Vector3.new(0, 8, 0)
end

local function vortexPattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local spin = cfgVal(cfg, "spin", 12)
	local height = cfgVal(cfg, "height", 5)
	local q = ratio(i, n)
	local angle = (i - 1) * math.pi * 2 / math.max(n, 1) + t * d
	local rr = math.sqrt(q) * r * 1.8
	return Vector3.new(math.cos(angle + q * spin) * rr, height - q * height, math.sin(angle + q * spin) * rr)
end

local function doubleRingPattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local gap = cfgVal(cfg, "gap", 0.45)
	local angle = (i - 1) * math.pi * 2 / math.max(n, 1) + t * d
	local ring = i % 2
	local rr = r * (1 + ring * gap)
	return Vector3.new(math.cos(angle * 2) * rr, 2 + ring * 3, math.sin(angle * 2) * rr)
end

local function galaxyPattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local spin = cfgVal(cfg, "spin", 12)
	local q = ratio(i, n)
	local angle = (i - 1) * math.pi * 2 / math.max(n, 1) + t * d
	local rr = math.sqrt(q) * r * 1.8
	return Vector3.new(math.cos(angle + q * spin) * rr, 5 - q * 5, math.sin(angle + q * spin) * rr)
end

local function cubePattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local spread = cfgVal(cfg, "spread", 1)
	local side = math.max(1, math.ceil(n ^ (1 / 3)))
	local zeroIndex = i - 1
	local x = zeroIndex % side
	local y = math.floor(zeroIndex / side) % side
	local z = math.floor(zeroIndex / (side * side))
	return Vector3.new((x - (side - 1) / 2) * s * spread, (y - (side - 1) / 2) * vs * spread + 3, (z - (side - 1) / 2) * s * spread)
end

local function diamondPattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local stretchY = cfgVal(cfg, "stretchY", 1)
	local y = 1 - 2 * ((i - 0.5) / n)
	local radial = math.sqrt(math.max(0, 1 - y * y))
	local p = Vector3.new(math.cos(i * 2.399963) * radial, y, math.sin(i * 2.399963) * radial)
	local l1 = math.max(math.abs(p.X) + math.abs(p.Y) + math.abs(p.Z), 0.001)
	p = p / l1
	local rr = baseR(n, r, s)
	return Vector3.new(p.X * rr, p.Y * rr * stretchY, p.Z * rr) + Vector3.new(0, 3, 0)
end

local function shieldPattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local curvature = cfgVal(cfg, "curvature", 1)
	local cols = math.max(2, math.ceil(math.sqrt(n * 1.7)))
	local row = math.floor((i - 1) / cols)
	local x = ((i - 1) % cols - (cols - 1) / 2) * s
	return Vector3.new(x, 7 - row * vs, -8 + (x * x) / math.max(r * 5 / curvature, 8))
end

local function pulsePattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local amplitude = cfgVal(cfg, "amplitude", 0.18)
	local speed = cfgVal(cfg, "speed", 1)
	local angle = (i - 1) * math.pi * 2 / math.max(n, 1) + t * d
	local scale = (1 - amplitude) + math.sin(t * 3 * speed) * amplitude
	return Vector3.new(math.cos(angle) * r * scale, 3, math.sin(angle) * r * scale)
end

local function dnaPattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local turns = cfgVal(cfg, "turns", 4)
	local q = ratio(i, n)
	local strand = (i % 2 == 0) and math.pi or 0
	return Vector3.new(
		math.cos(q * math.pi * turns * 2 + t + strand) * r,
		-7 + q * 20,
		math.sin(q * math.pi * turns * 2 + t + strand) * r
	)
end

local function saturnPattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local ringScale = cfgVal(cfg, "ringScale", 1.35)
	local angle = (i - 1) * math.pi * 2 / math.max(n, 1) + t * d
	return Vector3.new(math.cos(angle) * r * ringScale, 3 + math.sin(angle) * r * 0.22, math.sin(angle) * r * 0.72)
end

local function seraphimRingsPattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local radiusScale = cfgVal(cfg, "radiusScale", 1)
	local ringCount = math.max(2, math.floor(cfgVal(cfg, "ringCount", 3)))
	local ringTilt = cfgVal(cfg, "ringTilt", 1)
	local angle = (i - 1) * math.pi * 2 / math.max(n, 1) + t * d
	local ring = (i - 1) % ringCount
	local p = Vector3.new(
		math.cos(angle * ringCount) * r * radiusScale,
		0,
		math.sin(angle * ringCount) * r * radiusScale
	)
	local frame = CFrame.Angles(ring * math.pi / ringCount * ringTilt, 0, ring * math.pi / 2 * ringTilt)
	return frame:VectorToWorldSpace(p) + Vector3.new(0, 3, 0)
end

local function starPattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local points = cfgVal(cfg, "points", 5)
	local depth = cfgVal(cfg, "depth", 0.65)
	local angle = (i - 1) * math.pi * 2 / math.max(n, 1) + t * d
	local wave = (math.cos(angle * points) + 1) * 0.5
	local rr = r * (0.45 + wave * depth)
	return Vector3.new(math.cos(angle) * rr, 3, math.sin(angle) * rr)
end

local function pyramidPattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local height = cfgVal(cfg, "height", 14)
	local q = ratio(i, n)
	local edge = (i - 1) % 4
	local rr = r * (1 - q)
	local a = math.pi / 4 + edge * math.pi / 2
	return Vector3.new(math.cos(a) * rr, -2 + q * height, math.sin(a) * rr)
end

local function wingsPattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local span = cfgVal(cfg, "span", 2)
	local q = ratio(i, n)
	local side = i % 2 == 0 and 1 or -1
	return Vector3.new(side * (3 + q * r * span), 9 - q * 7, 3 + q * 3)
end

local function tunnelPattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local ringDepth = cfgVal(cfg, "ringDepth", 6)
	local angle = (i - 1) * math.pi * 2 / math.max(n, 1) + t * d
	return Vector3.new(math.cos(angle) * r, 3 + math.sin(angle) * r, -7 - math.floor((i - 1) / 8) * ringDepth)
end

local function hourglassPattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local height = cfgVal(cfg, "height", 10)
	local q = ratio(i, n)
	local y = q * 2 - 1
	local rr = math.max(s, math.abs(y) * r)
	return Vector3.new(math.cos(i * 2.399963 + t) * rr, y * height + 3, math.sin(i * 2.399963 + t) * rr)
end

local function discPattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local radiusScale = cfgVal(cfg, "radiusScale", 1)
	local yOff = cfgVal(cfg, "yOffset", 0)
	local rr = math.sqrt((i - 0.5) / n) * r * radiusScale
	return Vector3.new(math.cos(i * 2.399963 + t) * rr, 3 + yOff, math.sin(i * 2.399963 + t) * rr)
end

local function arrowPattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local length = cfgVal(cfg, "length", 1)
	local q = ratio(i, n)
	local side = i % 2 == 0 and 1 or -1
	return Vector3.new(side * q * r, 3, -14 + q * r * length)
end

local function nebulaBloomPattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local spiral = cfgVal(cfg, "spiral", 0.42)
	local q = math.sqrt((i - 0.5) / n)
	local a = i * 2.399963 + t * spiral * d
	local radius = baseR(n, r, s) * q * (0.78 + 0.22 * math.sin(a * 3 + t))
	return Vector3.new(math.cos(a) * radius, 3 + math.sin(a * 2.1) * radius * 0.24, math.sin(a) * radius)
end

local function lotusPattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local petals = cfgVal(cfg, "petals", 4)
	local q = math.sqrt((i - 0.5) / n)
	local a = i * 2.399963 + t * 0.25 * d
	local radius = baseR(n, r, s) * q * (0.42 + 0.58 * math.abs(math.sin(a * petals)))
	return Vector3.new(math.cos(a) * radius, 2 + (1 - q) * 5 + math.cos(a * petals * 2) * 0.7, math.sin(a) * radius)
end

local function cloverPattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local lobes = cfgVal(cfg, "lobes", 2)
	local a = (i - 1) * 2 * math.pi / n + t * 0.45 * d
	local radius = math.max(r, s * n / (7 * math.pi)) * (0.35 + 0.72 * math.abs(math.cos(a * lobes)))
	return Vector3.new(math.cos(a) * radius, 3 + math.sin(a * lobes * 2) * 0.8, math.sin(a) * radius)
end

local function rosePattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local petals = cfgVal(cfg, "petals", 3.5)
	local a = (i - 1) * 2 * math.pi / n + t * 0.32 * d
	local radius = math.max(r, s * n / (9 * math.pi)) * math.abs(math.cos(a * petals))
	return Vector3.new(math.cos(a) * radius, 3 + math.sin(a * petals * 2) * 1.2, math.sin(a) * radius)
end

local function sunburstPattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local rays = cfgVal(cfg, "rays", 3)
	local a = (i - 1) * 2 * math.pi / n + t * 0.22 * d
	local ray = (i - 1) % rays
	local radius = math.max(r, s * n / (5 * math.pi)) * (0.5 + ray * (0.85 / rays))
	return Vector3.new(math.cos(a) * radius, 3 + (ray == rays - 1 and 1.5 or 0), math.sin(a) * radius)
end

local function cometTailPattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local curl = cfgVal(cfg, "curl", 3)
	local q = ratio(i, n)
	local a = q * math.pi * curl + t * 0.8 * d
	return Vector3.new(math.cos(a) * (1 - q) * r * 0.55, 5 - q * 5 + math.sin(a) * 0.8, -5 - q * math.max(r * 3, s * n * 0.35))
end

local function nautilusPattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local spiralTight = cfgVal(cfg, "spiralTight", 5.5)
	local q = ratio(i, n)
	local a = q * math.pi * spiralTight + t * 0.28 * d
	local radius = s * 0.5 + q * math.max(r * 1.8, s * math.sqrt(n))
	return Vector3.new(math.cos(a) * radius, 3 + q * 3, math.sin(a) * radius)
end

local function shellPattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local curl = cfgVal(cfg, "curl", 6)
	local q = ratio(i, n)
	local a = q * math.pi * curl + t * 0.25 * d
	local radius = math.max(1, r * (0.18 + q * 1.15))
	return Vector3.new(math.cos(a) * radius, (q - 0.5) * math.max(12, vs * 4) + 3, math.sin(a) * radius * (0.45 + q * 0.55))
end

local function jellyfishPattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local domeRatio = cfgVal(cfg, "domeRatio", 0.58)
	local strandLength = cfgVal(cfg, "strandLength", 3.6)
	local strandWave = cfgVal(cfg, "strandWave", 0.8)
	local domeCount = math.max(4, math.floor(n * domeRatio))
	if i <= domeCount then
		local q = (i - 0.5) / domeCount
		local y = math.sqrt(math.max(0, 1 - q))
		local a = i * 2.399963 + t * 0.35 * d
		local radius = r * math.sqrt(q)
		return Vector3.new(math.cos(a) * radius, 5 + y * r * 0.75, math.sin(a) * radius)
	end
	local k = i - domeCount
	local strands = math.max(1, n - domeCount)
	local a = k * 2 * math.pi / strands
	return Vector3.new(
		math.cos(a) * r * 0.62,
		3 - ((k - 1) % 4) * vs * (strandLength / 3.6) + math.sin(t * 2 + k) * strandWave,
		math.sin(a) * r * 0.62
	)
end

local function umbrellaPattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local handleDensity = cfgVal(cfg, "handleDensity", 1)
	local canopy = math.max(3, n - math.max(1, math.floor(n * 0.18)))
	if i <= canopy then
		local q = math.sqrt((i - 0.5) / canopy)
		local a = i * 2.399963
		local radius = q * r * 1.35
		return Vector3.new(math.cos(a) * radius, 9 - q * q * 5, math.sin(a) * radius)
	end
	local hi = i - canopy
	return Vector3.new(math.sin(hi * 0.7) * 0.35, 4 - hi * math.min(vs * handleDensity, 1.8), 0)
end

local function conePattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local height = cfgVal(cfg, "height", 14)
	local q = ratio(i, n)
	local a = i * 2.399963 + t * 0.35 * d
	local radius = math.max(s * 0.4, r * (1 - q))
	return Vector3.new(math.cos(a) * radius, -2 + q * height, math.sin(a) * radius)
end

local function funnelPattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local height = cfgVal(cfg, "height", 12)
	local q = ratio(i, n)
	local a = i * 2.399963 + t * 1.2 * d
	local radius = s * 0.5 + q * math.max(r * 1.8, s * math.sqrt(n))
	return Vector3.new(math.cos(a) * radius, 10 - q * height, math.sin(a) * radius)
end

local function cyclonePattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local bands = cfgVal(cfg, "bands", 3)
	bands = math.max(2, math.floor(bands))
	local band = (i - 1) % bands
	local slot = math.floor((i - 1) / bands)
	local bandCount = math.max(1, math.ceil((n - band) / bands))
	local q = band / math.max(bands - 1, 1)
	local a = slot * 2 * math.pi / bandCount + t * (2.2 - q * 0.9) * d
	local radius = r * (0.35 + q * 1.15)
	return Vector3.new(math.cos(a) * radius, -2 + q * 14, math.sin(a) * radius)
end

local function mobiusPattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local thickness = cfgVal(cfg, "thickness", 0.55)
	local u = ratio(i, n) * 2 * math.pi + t * 0.35 * d
	local v = ((i - 1) % 3 - 1) * s * thickness
	return Vector3.new((r + v * math.cos(u / 2)) * math.cos(u), 3 + v * math.sin(u / 2), (r + v * math.cos(u / 2)) * math.sin(u))
end

local function lissajousPattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local freqX = cfgVal(cfg, "freqX", 3)
	local freqY = cfgVal(cfg, "freqY", 4)
	local freqZ = cfgVal(cfg, "freqZ", 5)
	local u = ratio(i, n) * 2 * math.pi + t * 0.32 * d
	return Vector3.new(math.sin(freqX * u) * r * 1.35, 3 + math.sin(freqY * u + math.pi / 3) * r * 0.85, math.sin(freqZ * u) * r)
end

local function atomPattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local nucleusRatio = cfgVal(cfg, "nucleusRatio", 0.14)
	local electronRadius = cfgVal(cfg, "electronRadius", 0.92)
	local electronRadiusZ = cfgVal(cfg, "electronRadiusZ", 0.62)
	local nucleusCount = math.max(1, math.floor(n * nucleusRatio))
	if i <= nucleusCount then
		local a = i * 2.399963 + t * 0.4
		local y = 1 - 2 * ((i - 0.5) / nucleusCount)
		local radial = math.sqrt(math.max(0, 1 - y * y))
		return Vector3.new(math.cos(a) * radial * s, 3 + y * s, math.sin(a) * radial * s)
	end
	local electron = i - nucleusCount
	local electronCount = n - nucleusCount
	local ringIdx = (electron - 1) % 3
	local slot = math.floor((electron - 1) / 3)
	local count = math.max(1, math.floor((electronCount + 2 - ringIdx) / 3))
	local a = slot * 2 * math.pi / count + t * (1.15 + ringIdx * 0.2) * (ringIdx == 1 and -d or d)
	local point = Vector3.new(math.cos(a) * r * electronRadius, 0, math.sin(a) * r * electronRadiusZ)
	local frame = CFrame.Angles(ringIdx * math.pi / 3, ringIdx * math.pi / 5, (ringIdx - 1) * math.pi / 3)
	return frame:VectorToWorldSpace(point) + Vector3.new(0, 3, 0)
end

local function electronCloudPattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local noise = cfgVal(cfg, "noise", 0.7)
	local y = 1 - 2 * ((i - 0.5) / n)
	local radial = math.sqrt(math.max(0, 1 - y * y))
	local jitter = 0.65 + ((math.sin(i * 91.73) * 43758.5453) % 1) * noise
	local a = i * 2.399963 + t * 0.18 * d
	local radius = baseR(n, r, s) * jitter
	return Vector3.new(math.cos(a) * radial * radius, 3 + y * radius, math.sin(a) * radial * radius)
end

local function solarSystemPattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local rings = cfgVal(cfg, "rings", 5)
	rings = math.max(2, math.floor(rings))
	if i == 1 then return Vector3.new(0, 3, 0) end
	local ringIdx = 1 + ((i - 2) % rings)
	local slot = math.floor((i - 2) / rings)
	local count = math.max(1, math.ceil((n - 1 - (ringIdx - 1)) / rings))
	local radius = r * (0.42 + ringIdx * 0.32)
	local a = slot * 2 * math.pi / count + t * d * (1.5 / math.sqrt(ringIdx))
	return Vector3.new(math.cos(a) * radius, 3 + (ringIdx - 3) * 0.28, math.sin(a) * radius)
end

local function crossPattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local armLength = cfgVal(cfg, "armLength", 1)
	local arm = (i - 1) % 4
	local step = math.floor((i - 1) / 4) + 1
	local distance = step * s * armLength
	local a = arm * math.pi / 2
	return Vector3.new(math.cos(a) * distance, 3 + math.sin(a) * distance, -7)
end

local function xWingPattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local spread = cfgVal(cfg, "spread", 1)
	local arm = (i - 1) % 4
	local step = math.floor((i - 1) / 4) + 1
	local distance = step * s * spread
	local a = math.pi / 4 + arm * math.pi / 2
	return Vector3.new(math.cos(a) * distance, 3 + math.sin(a) * distance, -7 + (arm % 2 == 0 and step or -step) * 0.35)
end

local function bowPattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local arcSize = cfgVal(cfg, "arcSize", 1)
	local arcCount = math.max(4, math.floor(n * 0.72))
	if i <= arcCount then
		local q = ratio(i, arcCount) * 2 - 1
		return Vector3.new(q * r * arcSize, 4 + q * r * arcSize, -6 + (1 - q * q) * r * 0.68)
	end
	local q = ratio(i - arcCount, math.max(1, n - arcCount)) * 2 - 1
	return Vector3.new(q * r * arcSize, 4 + q * r * arcSize, -6)
end

local function crescentPattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local width = cfgVal(cfg, "width", 1.4)
	local a = -math.pi * 0.72 + ratio(i, n) * math.pi * 1.44
	return Vector3.new(math.sin(a) * r * width, 3 + math.cos(a) * r * width, -5 + math.cos(a) * r * 0.35)
end

local function twinCrescentPattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local width = cfgVal(cfg, "width", 0.72)
	local separation = cfgVal(cfg, "separation", 0.62)
	local side = i % 2 == 0 and 1 or -1
	local k = math.ceil(i / 2)
	local a = -math.pi * 0.7 + ratio(k, math.ceil(n / 2)) * math.pi * 1.4
	return Vector3.new(
		side * (r * separation + math.sin(a) * r * width),
		3 + math.cos(a) * r,
		-5 + side * math.cos(a) * 1.2
	)
end

local function fanPattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local spread = cfgVal(cfg, "spread", 0.5)
	local q = ratio(i, n)
	local a = (-spread + q * spread * 2) * math.pi * 0.5
	local band = (i - 1) % 3
	local radius = r * (0.75 + band * 0.3)
	return Vector3.new(math.sin(a) * radius, -2 + math.cos(a) * radius, -6 + band)
end

local function peacockPattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local spread = cfgVal(cfg, "spread", 1)
	local q = ratio(i, n)
	local a = -1.28 + q * 2.56
	local band = (i - 1) % 3
	local radius = math.max(r * 1.25, s * math.sqrt(n) * 0.78) * (0.72 + band * 0.18) * spread
	return Vector3.new(math.sin(a) * radius, -1 + math.cos(a) * radius * 0.92, 4.5 + band * 1.1)
end

local function gridWavePattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local amplitude = cfgVal(cfg, "amplitude", 1)
	local frequency = cfgVal(cfg, "frequency", 1)
	local columns = math.ceil(math.sqrt(n))
	local row = math.floor((i - 1) / columns)
	local column = (i - 1) % columns
	local centerGrid = (columns - 1) / 2
	return Vector3.new(
		(column - centerGrid) * s,
		3 + math.sin(t * 2 * frequency + column * 0.7 + row * 0.55) * vs * amplitude,
		-7 + (row - centerGrid) * s
	)
end

local function checkerWavePattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local amplitude = cfgVal(cfg, "amplitude", 1)
	local frequency = cfgVal(cfg, "frequency", 1)
	local columns = math.ceil(math.sqrt(n))
	local row = math.floor((i - 1) / columns)
	local column = (i - 1) % columns
	local centerGrid = (columns - 1) / 2
	local sign = (row + column) % 2 == 0 and 1 or -1
	return Vector3.new(
		(column - centerGrid) * s,
		3 + sign * (2.5 + math.sin(t * 2.4 * frequency) * 1.2) * amplitude,
		-7 + (row - centerGrid) * s
	)
end

local function staircasePattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local stepHeight = cfgVal(cfg, "stepHeight", 1)
	local steps = math.max(2, math.ceil(math.sqrt(n)))
	local step = (i - 1) % steps
	local lane = math.floor((i - 1) / steps)
	return Vector3.new((step - (steps - 1) / 2) * s, -2 + step * vs * stepHeight, -6 + lane * s)
end

local function ladderPattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local rungSpacing = cfgVal(cfg, "rungSpacing", 1)
	local row = math.floor((i - 1) / 2)
	local side = i % 2 == 0 and 1 or -1
	return Vector3.new(side * r * 0.7, -2 + row * vs * rungSpacing, -7 + ((row % 3 == 0) and side * s * 0.2 or 0))
end

local function fortressPattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local columnFactor = cfgVal(cfg, "columnFactor", 1.8)
	local curvature = cfgVal(cfg, "curvature", 0.18)
	local battlementHeight = cfgVal(cfg, "battlementHeight", 1.4)
	local columns = math.max(4, math.ceil(math.sqrt(n * columnFactor)))
	local row = math.floor((i - 1) / columns)
	local column = (i - 1) % columns
	local x = (column - (columns - 1) / 2) * s
	local battlement = row == 0 and (column % 2 == 0 and vs * battlementHeight or 0) or 0
	return Vector3.new(x, 7 - row * vs + battlement, -9 + math.abs(x) * curvature)
end

local function domePattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local height = cfgVal(cfg, "height", 1)
	local q = (i - 0.5) / n
	local y = q
	local radial = math.sqrt(math.max(0, 1 - y * y))
	local a = i * 2.399963 + t * 0.25 * d
	local radius = baseR(n, r, s)
	return Vector3.new(math.cos(a) * radial * radius, 1 + y * radius * height, math.sin(a) * radial * radius)
end

local function cagePattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local ribs = cfgVal(cfg, "ribs", 6)
	ribs = math.max(3, math.floor(ribs))
	local rib = (i - 1) % ribs
	local level = math.floor((i - 1) / ribs)
	local levels = math.max(1, math.ceil(n / ribs))
	local q = levels == 1 and 0.5 or level / (levels - 1)
	local y = (q * 2 - 1) * r
	local radial = math.sqrt(math.max(0, r * r - y * y))
	local a = rib * 2 * math.pi / ribs + t * 0.18 * d
	return Vector3.new(math.cos(a) * radial, 3 + y, math.sin(a) * radial)
end

local function torusPattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local tubeScale = cfgVal(cfg, "tubeScale", 0.32)
	local major = i * 2.399963 + t * 0.35 * d
	local minorSegments = math.max(3, math.floor(math.sqrt(n)))
	local minor = ((i - 1) % minorSegments) * 2 * math.pi / minorSegments
	local tube = math.max(s, r * tubeScale)
	return Vector3.new(
		(r + tube * math.cos(minor)) * math.cos(major),
		3 + tube * math.sin(minor),
		(r + tube * math.cos(minor)) * math.sin(major)
	)
end

local function knotPattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local knotScale = cfgVal(cfg, "knotScale", 0.62)
	local u = ratio(i, n) * 2 * math.pi + t * 0.28 * d
	local scale = r * knotScale
	return Vector3.new(
		(2 + math.cos(3 * u)) * math.cos(2 * u) * scale,
		3 + math.sin(3 * u) * scale,
		(2 + math.cos(3 * u)) * math.sin(2 * u) * scale
	)
end

local function ribbonPattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local length = cfgVal(cfg, "length", 1)
	local waveFreq = cfgVal(cfg, "waveFreq", 6)
	local q = ratio(i, n)
	local x = (q - 0.5) * math.max(r * 4, s * n * 0.48) * length
	local wave = q * math.pi * waveFreq + t * 1.4 * d
	return Vector3.new(x, 3 + math.sin(wave) * 4, math.cos(wave) * 2.2)
end

local function sawbladePattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local toothLength = cfgVal(cfg, "toothLength", 1.4)
	local a = (i - 1) * 2 * math.pi / n + t * 0.9 * d
	local tooth = (i - 1) % 2
	local radius = math.max(r * 1.3, s * n / (2 * math.pi)) + tooth * s * toothLength
	return Vector3.new(math.cos(a) * radius, 3 + tooth * 0.5, math.sin(a) * radius)
end

local function shurikenPattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local armLength = cfgVal(cfg, "armLength", 1.7)
	local arm = (i - 1) % 4
	local along = 0.25 + math.floor((i - 1) / 4) / math.max(math.ceil(n / 4), 1)
	local a = arm * math.pi / 2 + t * 0.7 * d + along * 0.55
	return Vector3.new(math.cos(a) * r * armLength * along, 3 + math.sin(along * math.pi) * 1.5, math.sin(a) * r * armLength * along)
end

local function compassPattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local reach = cfgVal(cfg, "reach", 1.8)
	local arm = (i - 1) % 4
	local step = math.floor((i - 1) / 4) + 1
	local maxStep = math.max(1, math.ceil(n / 4))
	local distance = step / maxStep * r * reach
	local a = arm * math.pi / 2
	return Vector3.new(math.cos(a) * distance, 3 + (step == maxStep and 1.5 or 0), math.sin(a) * distance)
end

local function phoenixPattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local span = cfgVal(cfg, "span", 2.15)
	local side = i % 2 == 0 and 1 or -1
	local q = ratio(math.ceil(i / 2), math.ceil(n / 2))
	local s2 = math.max(r * span, s * math.sqrt(n) * span)
	return Vector3.new(side * (2 + q * s2), 8 - q * 6 + math.sin(q * math.pi * 2.6) * 2.2, 3.5 + q * 2.5)
end

local function dragonSpinePattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local length = cfgVal(cfg, "length", 4)
	local q = ratio(i, n)
	local x = (q - 0.5) * math.max(r * length, s * n * 0.52)
	return Vector3.new(x, 4 + math.sin(q * math.pi * 5 + t * 1.4) * 4, 3.5 + math.cos(q * math.pi * 3 + t) * 2.5)
end

local function gyroscopePattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local radiusScale = cfgVal(cfg, "radiusScale", 1.25)
	local ringIdx = (i - 1) % 3
	local slot = math.floor((i - 1) / 3)
	local count = math.max(1, math.ceil((n - ringIdx) / 3))
	local angle = slot * math.pi * 2 / count + t * d * (0.7 + ringIdx * 0.22)
	local point = Vector3.new(math.cos(angle) * r * radiusScale, 0, math.sin(angle) * r * radiusScale)
	return CFrame.Angles(ringIdx * math.pi / 3, ringIdx * math.pi / 5, ringIdx * math.pi / 2):VectorToWorldSpace(point) + Vector3.new(0, 3, 0)
end

local function tridentPattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local shaftRatio = cfgVal(cfg, "shaftRatio", 0.38)
	local shaft = math.max(3, math.floor(n * shaftRatio))
	if i <= shaft then return Vector3.new(0, -8 + (i - 1) * vs, -9) end
	local k = i - shaft
	local prong = (k - 1) % 3 - 1
	local row = math.floor((k - 1) / 3)
	return Vector3.new(prong * s * (1.5 + row * 0.08), 2 + row * vs, -9 + (math.abs(prong) * row * 0.18))
end

local function prismFramePattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local scale = cfgVal(cfg, "scale", 1)
	local edge = (i - 1) % 9
	local step = math.floor((i - 1) / 9)
	local steps = math.max(1, math.ceil(n / 9))
	local q = step / steps
	local a = edge % 3 * math.pi * 2 / 3
	local b = (edge + 1) % 3 * math.pi * 2 / 3
	local r2 = r * scale
	if edge < 6 then
		local level = edge < 3 and -1 or 1
		return Vector3.new(math.cos(a) * r2, level * r2 * 0.58 + 3, math.sin(a) * r2):Lerp(
			Vector3.new(math.cos(b) * r2, level * r2 * 0.58 + 3, math.sin(b) * r2), q)
	end
	return Vector3.new(math.cos(a) * r2, -r2 * 0.58 + 3, math.sin(a) * r2):Lerp(
		Vector3.new(math.cos(a) * r2, r2 * 0.58 + 3, math.sin(a) * r2), q)
end

local function constellationPattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local scale = cfgVal(cfg, "scale", 1.25)
	local group = (i - 1) % 7
	local q = ratio(math.floor((i - 1) / 7) + 1, math.ceil(n / 7))
	local anchors = {
		Vector3.new(-1.3, 0.25, -0.4), Vector3.new(-0.75, 1.05, 0.2), Vector3.new(-0.15, 0.35, -0.2),
		Vector3.new(0.35, 0.9, 0.35), Vector3.new(0.9, 0.15, -0.3), Vector3.new(1.25, 0.75, 0.15),
		Vector3.new(0.45, -0.55, 0.1),
	}
	local a = anchors[group + 1]
	local b = anchors[(group + 1) % #anchors + 1]
	return a:Lerp(b, q) * r * scale + Vector3.new(0, 3, -7)
end

local function aegisArcPattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local width = cfgVal(cfg, "width", 1)
	local columns = math.max(4, math.ceil(math.sqrt(n * 1.8)))
	local row = math.floor((i - 1) / columns)
	local col = (i - 1) % columns
	local x = (col - (columns - 1) / 2) * s * width
	local y = 9 - row * vs
	local curve = (x * x) / math.max(r * 3.5, 18)
	return Vector3.new(x, y, -10 + curve)
end

local function gravityWellPattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local tightness = cfgVal(cfg, "tightness", 2.2)
	local q = math.sqrt((i - 0.5) / n)
	local a = q * math.pi * 10 + t * 1.1 * d
	local radius = math.max(s, q * r * tightness)
	return Vector3.new(math.cos(a) * radius, 8 - q * q * 16, math.sin(a) * radius)
end

local function meteorCrownPattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local radiusScale = cfgVal(cfg, "radiusScale", 1)
	local point = (i - 1) % 8
	local row = math.floor((i - 1) / 8)
	local a = point * math.pi / 4 + t * 0.3 * d
	local height = 12 + ((point % 2 == 0) and 7 or 2) - row * vs * 0.72
	return Vector3.new(math.cos(a) * (r * radiusScale + row * s * 0.12), height, math.sin(a) * (r * radiusScale + row * s * 0.12))
end

local function sentinelWingsPattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local span = cfgVal(cfg, "span", 2.1)
	local side = i % 2 == 0 and 1 or -1
	local k = math.floor((i - 1) / 2)
	local rows = math.max(1, math.ceil(n / 8))
	local row = k % rows
	local feather = math.floor(k / rows)
	local q = rows == 1 and 0 or row / (rows - 1)
	return Vector3.new(
		side * (4 + q * r * span),
		11 - q * 10 - feather * vs * 0.7,
		2 + feather * s * 0.9 + math.sin(t * 1.3 + q * 4) * 0.5
	)
end

local function orbitalCrossPattern(i, n, t, entry, slotAngle, cfg, r, s, vs, d)
	local reach = cfgVal(cfg, "reach", 1.7)
	local arm = (i - 1) % 4
	local step = math.floor((i - 1) / 4) + 1
	local steps = math.max(1, math.ceil(n / 4))
	local distance = step / steps * r * reach
	local a = arm * math.pi / 2 + t * 0.5 * d
	return Vector3.new(math.cos(a) * distance, 3 + math.sin(t * 1.6 + step * 0.4) * 0.8, math.sin(a) * distance)
end

-- ============ SHAPE REGISTRATION ============
local function registerShape(name, def)
	def.settings = def.settings or {}
	def.meta = def.meta or {}
	def.defaults = {}
	for k, v in pairs(def.settings) do def.defaults[k] = v end
	SHAPES[name] = def
	table.insert(SHAPE_ORDER, name)
end

registerShape("Ring", {
	layer = true, fn = ringPattern,
	settings = { layerGap = 6, layerTilt = 0.65 },
	meta = {
		layerGap  = { label = "Layer Gap",  min = 2, max = 20,  step = 0.5, onChange = function() assignLayers() end },
		layerTilt = { label = "Layer Tilt", min = 0, max = 1.5, step = 0.05 },
	},
})

registerShape("Tornado", { fn = tornadoPattern,
	settings = { twist = 16, heightSpan = 22 },
	meta = {
		twist      = { label = "Twist",  min = 4,  max = 32, step = 0.5 },
		heightSpan = { label = "Height", min = 10, max = 40, step = 1 },
	},
})

registerShape("Line", { fn = linePattern,
	settings = { spacing = 1, zOffset = -8 },
	meta = {
		spacing = { label = "Spacing",  min = 0.3, max = 3, step = 0.05 },
		zOffset = { label = "Z Offset", min = -30, max = 0, step = 0.5 },
	},
})

registerShape("Wall", { fn = wallPattern,
	settings = { columnFactor = 1.6, zOffset = -8 },
	meta = {
		columnFactor = { label = "Column Factor", min = 0.5, max = 3, step = 0.05 },
		zOffset      = { label = "Z Offset",      min = -30, max = 0, step = 0.5 },
	},
})

registerShape("Spiral Wall", { fn = spiralWallPattern,
	settings = { amplitude = 2, columnFactor = 1.6 },
	meta = {
		amplitude    = { label = "Amplitude",     min = 0,   max = 6, step = 0.1 },
		columnFactor = { label = "Column Factor", min = 0.5, max = 3, step = 0.05 },
	},
})

registerShape("Infinity", { fn = infinityPattern,
	settings = { radiusScale = 1, crossingHeight = 0.35 },
	meta = {
		radiusScale    = { label = "Radius",          min = 0.5, max = 2.5, step = 0.05 },
		crossingHeight = { label = "Crossing Height", min = 0,   max = 2,   step = 0.05 },
	},
})

registerShape("Wave", { fn = wavePattern,
	settings = { amplitude = 3, frequency = 1 },
	meta = {
		amplitude = { label = "Amplitude", min = 0,   max = 8,   step = 0.1 },
		frequency = { label = "Frequency", min = 0.2, max = 3,   step = 0.05 },
	},
})

registerShape("Sphere", { fn = spherePattern,
	settings = { noise = 0 },
	meta = { noise = { label = "Noise", min = 0, max = 2, step = 0.05 } },
})

registerShape("Sinking", { fn = sinkingPattern,
	settings = { sinkDepth = 7 },
	meta = { sinkDepth = { label = "Sink Depth", min = 2, max = 14, step = 0.5 } },
})

registerShape("Helix", { fn = helixPattern,
	settings = { turns = 4, heightSpan = 20 },
	meta = {
		turns      = { label = "Turns",  min = 1, max = 10, step = 0.25 },
		heightSpan = { label = "Height", min = 8, max = 40, step = 1 },
	},
})

registerShape("Crown", { fn = crownPattern,
	settings = { points = 7, spikeHeight = 7 },
	meta = {
		points      = { label = "Points", min = 3, max = 14, step = 1 },
		spikeHeight = { label = "Spike",  min = 1, max = 14, step = 0.5 },
	},
})

registerShape("Halo", { fn = haloPattern,
	settings = { tilt = 0.22 },
	meta = { tilt = { label = "Tilt", min = 0, max = 0.8, step = 0.02 } },
})

registerShape("Vortex", { fn = vortexPattern,
	settings = { spin = 12, height = 5 },
	meta = {
		spin   = { label = "Spin",   min = 2, max = 24, step = 0.5 },
		height = { label = "Height", min = 2, max = 14, step = 0.5 },
	},
})

registerShape("Galaxy", { fn = galaxyPattern,
	settings = { spin = 12 },
	meta = { spin = { label = "Spin", min = 4, max = 24, step = 0.5 } },
})

registerShape("Double Ring", { fn = doubleRingPattern,
	settings = { gap = 0.45 },
	meta = { gap = { label = "Ring Gap", min = 0.1, max = 1.5, step = 0.05 } },
})

registerShape("Cube", { fn = cubePattern,
	settings = { spread = 1 },
	meta = { spread = { label = "Spread", min = 0.5, max = 2, step = 0.05 } },
})

registerShape("Diamond", { fn = diamondPattern,
	settings = { stretchY = 1 },
	meta = { stretchY = { label = "Stretch Y", min = 0.3, max = 2.5, step = 0.05 } },
})

registerShape("Shield", { fn = shieldPattern,
	settings = { curvature = 1 },
	meta = { curvature = { label = "Curvature", min = 0.2, max = 4, step = 0.05 } },
})

registerShape("Pulse", { fn = pulsePattern,
	settings = { amplitude = 0.18, speed = 1 },
	meta = {
		amplitude = { label = "Amplitude", min = 0,   max = 0.6, step = 0.02 },
		speed     = { label = "Speed",     min = 0.2, max = 4,   step = 0.05 },
	},
})

registerShape("DNA", { fn = dnaPattern,
	settings = { turns = 4 },
	meta = { turns = { label = "Turns", min = 1, max = 10, step = 0.25 } },
})

registerShape("Saturn", { fn = saturnPattern,
	settings = { ringScale = 1.35 },
	meta = { ringScale = { label = "Ring Scale", min = 0.6, max = 2.5, step = 0.05 } },
})

registerShape("Seraphim Rings", { fn = seraphimRingsPattern,
	settings = { radiusScale = 1, ringCount = 3, ringTilt = 1 },
	meta = {
		radiusScale = { label = "Radius",     min = 0.4, max = 2.5, step = 0.05 },
		ringCount   = { label = "Ring Count", min = 2,   max = 6,   step = 1 },
		ringTilt    = { label = "Ring Tilt",  min = 0.2, max = 1.8, step = 0.05 },
	},
})

registerShape("Star", { fn = starPattern,
	settings = { points = 5, depth = 0.65 },
	meta = {
		points = { label = "Points", min = 3,   max = 14,  step = 1 },
		depth  = { label = "Depth",  min = 0.2, max = 1.5, step = 0.05 },
	},
})

registerShape("Pyramid", { fn = pyramidPattern,
	settings = { height = 14 },
	meta = { height = { label = "Height", min = 4, max = 26, step = 1 } },
})

registerShape("Wings", { fn = wingsPattern,
	settings = { span = 2 },
	meta = { span = { label = "Span", min = 0.5, max = 3, step = 0.05 } },
})

registerShape("Tunnel", { fn = tunnelPattern,
	settings = { ringDepth = 6 },
	meta = { ringDepth = { label = "Ring Depth", min = 2, max = 14, step = 0.5 } },
})

registerShape("Hourglass", { fn = hourglassPattern,
	settings = { height = 10 },
	meta = { height = { label = "Height", min = 4, max = 20, step = 0.5 } },
})

registerShape("Disc", { fn = discPattern,
	settings = { radiusScale = 1, yOffset = 0 },
	meta = {
		radiusScale = { label = "Radius",   min = 0.3, max = 2,   step = 0.05 },
		yOffset     = { label = "Y Offset", min = -10, max = 10,  step = 0.5 },
	},
})

registerShape("Arrow", { fn = arrowPattern,
	settings = { length = 1 },
	meta = { length = { label = "Length", min = 0.5, max = 2.5, step = 0.05 } },
})

registerShape("Nebula Bloom", { fn = nebulaBloomPattern,
	settings = { spiral = 0.42 },
	meta = { spiral = { label = "Spiral", min = 0.1, max = 1.5, step = 0.02 } },
})

registerShape("Lotus", { fn = lotusPattern,
	settings = { petals = 4 },
	meta = { petals = { label = "Petals", min = 2, max = 10, step = 0.5 } },
})

registerShape("Clover", { fn = cloverPattern,
	settings = { lobes = 2 },
	meta = { lobes = { label = "Lobes", min = 2, max = 5, step = 0.5 } },
})

registerShape("Rose", { fn = rosePattern,
	settings = { petals = 3.5 },
	meta = { petals = { label = "Petals", min = 2, max = 8, step = 0.5 } },
})

registerShape("Sunburst", { fn = sunburstPattern,
	settings = { rays = 3 },
	meta = { rays = { label = "Rays", min = 2, max = 8, step = 1 } },
})

registerShape("Comet Tail", { fn = cometTailPattern,
	settings = { curl = 3 },
	meta = { curl = { label = "Curl", min = 1, max = 8, step = 0.25 } },
})

registerShape("Nautilus", { fn = nautilusPattern,
	settings = { spiralTight = 5.5 },
	meta = { spiralTight = { label = "Tightness", min = 2, max = 10, step = 0.25 } },
})

registerShape("Shell", { fn = shellPattern,
	settings = { curl = 6 },
	meta = { curl = { label = "Curl", min = 3, max = 12, step = 0.25 } },
})

registerShape("Jellyfish", { fn = jellyfishPattern,
	settings = { domeRatio = 0.58, strandLength = 3.6, strandWave = 0.8 },
	meta = {
		domeRatio    = { label = "Dome Ratio",    min = 0.3, max = 0.85, step = 0.02 },
		strandLength = { label = "Strand Length", min = 1,   max = 8,    step = 0.1 },
		strandWave   = { label = "Strand Wave",   min = 0,   max = 3,    step = 0.05 },
	},
})

registerShape("Umbrella", { fn = umbrellaPattern,
	settings = { handleDensity = 1 },
	meta = { handleDensity = { label = "Handle Density", min = 0.4, max = 2, step = 0.05 } },
})

registerShape("Cone", { fn = conePattern,
	settings = { height = 14 },
	meta = { height = { label = "Height", min = 4, max = 26, step = 1 } },
})

registerShape("Funnel", { fn = funnelPattern,
	settings = { height = 12 },
	meta = { height = { label = "Height", min = 4, max = 26, step = 1 } },
})

registerShape("Cyclone", { fn = cyclonePattern,
	settings = { bands = 3 },
	meta = { bands = { label = "Bands", min = 2, max = 8, step = 1 } },
})

registerShape("Mobius", { fn = mobiusPattern,
	settings = { thickness = 0.55 },
	meta = { thickness = { label = "Thickness", min = 0.1, max = 1.2, step = 0.05 } },
})

registerShape("Lissajous", { fn = lissajousPattern,
	settings = { freqX = 3, freqY = 4, freqZ = 5 },
	meta = {
		freqX = { label = "Freq X", min = 1, max = 7, step = 1 },
		freqY = { label = "Freq Y", min = 1, max = 7, step = 1 },
		freqZ = { label = "Freq Z", min = 1, max = 7, step = 1 },
	},
})

registerShape("Atom", { fn = atomPattern,
	settings = { nucleusRatio = 0.14, electronRadius = 0.92, electronRadiusZ = 0.62 },
	meta = {
		nucleusRatio    = { label = "Nucleus Ratio",   min = 0.05, max = 0.35, step = 0.01 },
		electronRadius  = { label = "Electron Radius", min = 0.4,  max = 1.6,  step = 0.02 },
		electronRadiusZ = { label = "Electron Depth",  min = 0.3,  max = 1.2,  step = 0.02 },
	},
})

registerShape("Electron Cloud", { fn = electronCloudPattern,
	settings = { noise = 0.7 },
	meta = { noise = { label = "Noise", min = 0, max = 2, step = 0.05 } },
})

registerShape("Solar System", { fn = solarSystemPattern,
	settings = { rings = 5 },
	meta = { rings = { label = "Rings", min = 2, max = 8, step = 1 } },
})

registerShape("Cross", { fn = crossPattern,
	settings = { armLength = 1 },
	meta = { armLength = { label = "Arm Length", min = 0.3, max = 3, step = 0.05 } },
})

registerShape("X-Wing", { fn = xWingPattern,
	settings = { spread = 1 },
	meta = { spread = { label = "Spread", min = 0.3, max = 3, step = 0.05 } },
})

registerShape("Bow", { fn = bowPattern,
	settings = { arcSize = 1 },
	meta = { arcSize = { label = "Arc Size", min = 0.4, max = 2.5, step = 0.05 } },
})

registerShape("Crescent", { fn = crescentPattern,
	settings = { width = 1.4 },
	meta = { width = { label = "Width", min = 0.5, max = 3, step = 0.05 } },
})

registerShape("Twin Crescent", { fn = twinCrescentPattern,
	settings = { width = 0.72, separation = 0.62 },
	meta = {
		width      = { label = "Width",      min = 0.3, max = 2,   step = 0.02 },
		separation = { label = "Separation", min = 0.1, max = 1.8, step = 0.02 },
	},
})

registerShape("Fan", { fn = fanPattern,
	settings = { spread = 0.5 },
	meta = { spread = { label = "Spread", min = 0.2, max = 1.5, step = 0.05 } },
})

registerShape("Peacock", { fn = peacockPattern,
	settings = { spread = 1 },
	meta = { spread = { label = "Spread", min = 0.4, max = 2.5, step = 0.05 } },
})

registerShape("Grid Wave", { fn = gridWavePattern,
	settings = { amplitude = 1, frequency = 1 },
	meta = {
		amplitude = { label = "Amplitude", min = 0, max = 4, step = 0.05 },
		frequency = { label = "Frequency", min = 0.2, max = 3, step = 0.05 },
	},
})

registerShape("Checker Wave", { fn = checkerWavePattern,
	settings = { amplitude = 1, frequency = 1 },
	meta = {
		amplitude = { label = "Amplitude", min = 0, max = 4, step = 0.05 },
		frequency = { label = "Frequency", min = 0.2, max = 3, step = 0.05 },
	},
})

registerShape("Staircase", { fn = staircasePattern,
	settings = { stepHeight = 1 },
	meta = { stepHeight = { label = "Step Height", min = 0.3, max = 4, step = 0.05 } },
})

registerShape("Ladder", { fn = ladderPattern,
	settings = { rungSpacing = 1 },
	meta = { rungSpacing = { label = "Rung Spacing", min = 0.3, max = 3, step = 0.05 } },
})

registerShape("Fortress", { fn = fortressPattern,
	settings = { columnFactor = 1.8, curvature = 0.18, battlementHeight = 1.4 },
	meta = {
		columnFactor     = { label = "Column Factor",     min = 0.5, max = 3,   step = 0.05 },
		curvature        = { label = "Curvature",         min = 0,   max = 0.6, step = 0.02 },
		battlementHeight = { label = "Battlement Height", min = 0,   max = 4,   step = 0.05 },
	},
})

registerShape("Dome", { fn = domePattern,
	settings = { height = 1 },
	meta = { height = { label = "Height", min = 0.3, max = 2.5, step = 0.05 } },
})

registerShape("Cage", { fn = cagePattern,
	settings = { ribs = 6 },
	meta = { ribs = { label = "Ribs", min = 3, max = 14, step = 1 } },
})

registerShape("Torus", { fn = torusPattern,
	settings = { tubeScale = 0.32 },
	meta = { tubeScale = { label = "Tube", min = 0.08, max = 0.9, step = 0.02 } },
})

registerShape("Knot", { fn = knotPattern,
	settings = { knotScale = 0.62 },
	meta = { knotScale = { label = "Scale", min = 0.2, max = 1.5, step = 0.02 } },
})

registerShape("Ribbon", { fn = ribbonPattern,
	settings = { length = 1, waveFreq = 6 },
	meta = {
		length   = { label = "Length",    min = 0.3, max = 2.5, step = 0.05 },
		waveFreq = { label = "Wave Freq", min = 2,   max = 14,  step = 0.5 },
	},
})

registerShape("Sawblade", { fn = sawbladePattern,
	settings = { toothLength = 1.4 },
	meta = { toothLength = { label = "Tooth Length", min = 0.3, max = 3, step = 0.05 } },
})

registerShape("Shuriken", { fn = shurikenPattern,
	settings = { armLength = 1.7 },
	meta = { armLength = { label = "Arm Length", min = 0.5, max = 3, step = 0.05 } },
})

registerShape("Compass", { fn = compassPattern,
	settings = { reach = 1.8 },
	meta = { reach = { label = "Reach", min = 0.5, max = 3, step = 0.05 } },
})

registerShape("Phoenix", { fn = phoenixPattern,
	settings = { span = 2.15 },
	meta = { span = { label = "Span", min = 0.5, max = 4, step = 0.05 } },
})

registerShape("Dragon Spine", { fn = dragonSpinePattern,
	settings = { length = 4 },
	meta = { length = { label = "Length", min = 1, max = 8, step = 0.1 } },
})

registerShape("Gyroscope", { fn = gyroscopePattern,
	settings = { radiusScale = 1.25 },
	meta = { radiusScale = { label = "Radius", min = 0.4, max = 2.5, step = 0.05 } },
})

registerShape("Trident", { fn = tridentPattern,
	settings = { shaftRatio = 0.38 },
	meta = { shaftRatio = { label = "Shaft Ratio", min = 0.15, max = 0.7, step = 0.02 } },
})

registerShape("Prism Frame", { fn = prismFramePattern,
	settings = { scale = 1 },
	meta = { scale = { label = "Scale", min = 0.3, max = 2.5, step = 0.05 } },
})

registerShape("Constellation", { fn = constellationPattern,
	settings = { scale = 1.25 },
	meta = { scale = { label = "Scale", min = 0.4, max = 3, step = 0.05 } },
})

registerShape("Aegis Arc", { fn = aegisArcPattern,
	settings = { width = 1 },
	meta = { width = { label = "Width", min = 0.3, max = 2.5, step = 0.05 } },
})

registerShape("Gravity Well", { fn = gravityWellPattern,
	settings = { tightness = 2.2 },
	meta = { tightness = { label = "Tightness", min = 0.8, max = 4, step = 0.05 } },
})

registerShape("Meteor Crown", { fn = meteorCrownPattern,
	settings = { radiusScale = 1 },
	meta = { radiusScale = { label = "Radius", min = 0.4, max = 2.5, step = 0.05 } },
})

registerShape("Sentinel Wings", { fn = sentinelWingsPattern,
	settings = { span = 2.1 },
	meta = { span = { label = "Span", min = 0.6, max = 4, step = 0.05 } },
})

registerShape("Orbital Cross", { fn = orbitalCrossPattern,
	settings = { reach = 1.7 },
	meta = { reach = { label = "Reach", min = 0.5, max = 3, step = 0.05 } },
})

-- ============ COLLECT / RELEASE ============
local function collectBlocks()
	lastBlockCount = 0
	ActiveBlocks = {}
	if not ActiveParts then return 0 end

	local myPlot = ActiveParts.Parent
	if not myPlot then return 0 end
	local ownerObj = myPlot:FindFirstChild("Owner")
	if not ownerObj or not ownerObj:IsA("ObjectValue") or ownerObj.Value ~= LPlayer then
		warn("[Shapes] This plot doesn't belong to you")
		return 0
	end

	for _, model in ipairs(ActiveParts:GetChildren()) do
		if not model:IsA("Model") then continue end
		local part = model.PrimaryPart
		if not part or part.Anchored then continue end

		part.CanCollide = false
		part.AssemblyLinearVelocity = Vector3.zero
		part.AssemblyAngularVelocity = Vector3.zero

		table.insert(ActiveBlocks, {
			part = part,
			originalColor = part.Color,
		})
	end

	assignLayers()
	lastBlockCount = #ActiveBlocks
	return #ActiveBlocks
end

local function releaseBlocks()
	holding = false
	lastBlockCount = 0
	for _, entry in ipairs(ActiveBlocks) do
		if entry.part and entry.part.Parent then
			entry.part.CanCollide = true
			entry.part.Color = entry.originalColor or entry.part.Color
		end
	end
	ActiveBlocks = {}
end

-- ============ RENDER ============
RunService.RenderStepped:Connect(function(dt)
	if not holding or #ActiveBlocks == 0 then return end
	local char = LPlayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	for i = #ActiveBlocks, 1, -1 do
		local entry = ActiveBlocks[i]
		if not entry.part or not entry.part.Parent then
			table.remove(ActiveBlocks, i)
		end
	end
	if #ActiveBlocks == 0 then holding = false return end

	if #ActiveBlocks ~= lastBlockCount then
		lastBlockCount = #ActiveBlocks
		assignLayers()
	end

	local center = root.Position
	local n = #ActiveBlocks
	local t = tick() * ORBIT_SPEED * CFG.speed
	local d = CFG.direction
	local shape = SHAPES[currentShape]
	if not shape then return end

	for i, entry in ipairs(ActiveBlocks) do
		local part = entry.part
		if part and part.Parent then
			local slotAngle
			if shape.layer then
				local layerAngleStep = (2 * math.pi) / math.max(entry.layerCount or n, 1)
				slotAngle = t * d
					+ (entry.layerSlot - 1) * layerAngleStep
					+ (entry.layerIndex or 0) * 0.35
			else
				slotAngle = t * d
			end

			local raw = shape.fn(i, n, t, entry, slotAngle, shape.settings, ORBIT_RADIUS, SPACING, SPACING, d)

			local targetPos = center + Vector3.new(
				raw.X * CFG.size,
				raw.Y * CFG.size + CFG.height,
				raw.Z * CFG.size
			)

			-- Preserve the block's current rotation; only drive position.
			local currentRotation = part.CFrame - part.Position
			part.CFrame = CFrame.new(targetPos) * currentRotation
			part.AssemblyLinearVelocity = Vector3.zero
			part.AssemblyAngularVelocity = Vector3.zero
		end
	end
end)

-- ============ GUI ============
local sg = Instance.new("ScreenGui")
sg.Name = "ShapesGui"
sg.ResetOnSpawn = false
sg.Parent = LPlayer:WaitForChild("PlayerGui")

local reopenBtn = Instance.new("TextButton")
reopenBtn.Size = UDim2.new(0, 80, 0, 26)
reopenBtn.Position = UDim2.new(0, 20, 0, 20)
reopenBtn.BackgroundColor3 = Color3.fromRGB(40, 95, 180)
reopenBtn.Text = "SHAPES"
reopenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
reopenBtn.Font = Enum.Font.GothamBold
reopenBtn.TextSize = 11
reopenBtn.BorderSizePixel = 0
reopenBtn.Visible = false
reopenBtn.Parent = sg
Instance.new("UICorner", reopenBtn).CornerRadius = UDim.new(0, 6)

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 700)
frame.Position = UDim2.new(0, 20, 0.5, -350)
frame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
frame.BorderSizePixel = 0
frame.Parent = sg
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 28)
title.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
title.Text = "SHAPES"
title.TextColor3 = Color3.fromRGB(90, 200, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.BorderSizePixel = 0
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 10)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 22, 0, 20)
closeBtn.Position = UDim2.new(1, -26, 0, 4)
closeBtn.BackgroundColor3 = Color3.fromRGB(70, 40, 40)
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.BorderSizePixel = 0
closeBtn.Parent = frame
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)

closeBtn.MouseButton1Click:Connect(function()
	frame.Visible = false
	reopenBtn.Visible = true
end)

reopenBtn.MouseButton1Click:Connect(function()
	frame.Visible = true
	reopenBtn.Visible = false
end)

local body = Instance.new("ScrollingFrame")
body.Size = UDim2.new(1, -8, 1, -70)
body.Position = UDim2.new(0, 4, 0, 32)
body.BackgroundTransparency = 1
body.BorderSizePixel = 0
body.ScrollBarThickness = 4
body.ScrollBarImageColor3 = Color3.fromRGB(90, 200, 255)
body.AutomaticCanvasSize = Enum.AutomaticSize.Y
body.CanvasSize = UDim2.new(0, 0, 0, 0)
body.Parent = frame

local bodyLayout = Instance.new("UIListLayout")
bodyLayout.Padding = UDim.new(0, 6)
bodyLayout.SortOrder = Enum.SortOrder.LayoutOrder
bodyLayout.Parent = body

local bodyPadding = Instance.new("UIPadding")
bodyPadding.PaddingLeft = UDim.new(0, 4)
bodyPadding.PaddingRight = UDim.new(0, 4)
bodyPadding.PaddingTop = UDim.new(0, 4)
bodyPadding.PaddingBottom = UDim.new(0, 8)
bodyPadding.Parent = body

local order = 0
local function nextOrder() order += 1 return order end

local function makeSectionHeader(text)
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, 0, 0, 16)
	lbl.BackgroundTransparency = 1
	lbl.Text = text
	lbl.TextColor3 = Color3.fromRGB(120, 120, 130)
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 9
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.LayoutOrder = nextOrder()
	lbl.Parent = body
	return lbl
end

local UNIVERSAL_SETTERS = {}

local function makeSlider(parent, label, default, min, max, step, onChange, registryKey)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, -8, 0, 32)
	container.BackgroundTransparency = 1
	container.LayoutOrder = nextOrder()
	container.Parent = parent

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(0.65, 0, 0, 14)
	nameLabel.Position = UDim2.new(0, 2, 0, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = label
	nameLabel.TextColor3 = Color3.fromRGB(190, 190, 200)
	nameLabel.Font = Enum.Font.Gotham
	nameLabel.TextSize = 10
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = container

	local valueLabel = Instance.new("TextLabel")
	valueLabel.Size = UDim2.new(0.35, -2, 0, 14)
	valueLabel.Position = UDim2.new(0.65, 0, 0, 0)
	valueLabel.BackgroundTransparency = 1
	valueLabel.Text = tostring(default)
	valueLabel.TextColor3 = Color3.fromRGB(90, 200, 255)
	valueLabel.Font = Enum.Font.GothamBold
	valueLabel.TextSize = 10
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.Parent = container

	local track = Instance.new("Frame")
	track.Size = UDim2.new(1, -4, 0, 4)
	track.Position = UDim2.new(0, 2, 0, 22)
	track.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
	track.BorderSizePixel = 0
	track.Parent = container
	Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(90, 200, 255)
	fill.BorderSizePixel = 0
	fill.Parent = track
	Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 12, 0, 12)
	knob.AnchorPoint = Vector2.new(0.5, 0.5)
	knob.Position = UDim2.new(0, 0, 0.5, 0)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.BorderSizePixel = 0
	knob.ZIndex = 2
	knob.Parent = track
	Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

	local current = default
	local function setValue(v, fire)
		v = math.clamp(v, min, max)
		v = math.floor(v / step + 0.5) * step
		current = v
		local pct = (max > min) and (v - min) / (max - min) or 0
		fill.Size = UDim2.new(pct, 0, 1, 0)
		knob.Position = UDim2.new(pct, 0, 0.5, 0)
		local decimals = step < 1 and 2 or 0
		valueLabel.Text = string.format("%." .. decimals .. "f", v)
		if fire and onChange then onChange(v) end
	end
	setValue(default, false)

	local dragging = false
	local function updateFromX(x)
		local abs = track.AbsolutePosition.X
		local width = track.AbsoluteSize.X
		if width <= 0 then return end
		local pct = math.clamp((x - abs) / width, 0, 1)
		setValue(min + pct * (max - min), true)
	end

	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			updateFromX(input.Position.X)
		end
	end)
	local connChanged = UIS.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			updateFromX(input.Position.X)
		end
	end)
	local connEnded = UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	container.Destroying:Connect(function()
		connChanged:Disconnect()
		connEnded:Disconnect()
	end)

	if registryKey then UNIVERSAL_SETTERS[registryKey] = setValue end
	return container, setValue
end

-- ---- Shape list ----
makeSectionHeader("SHAPE")

local listFrame = Instance.new("Frame")
listFrame.Size = UDim2.new(1, -8, 0, 220)
listFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
listFrame.BorderSizePixel = 0
listFrame.LayoutOrder = nextOrder()
listFrame.Parent = body
Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0, 6)

local shapeList = Instance.new("ScrollingFrame")
shapeList.Size = UDim2.new(1, -8, 1, -8)
shapeList.Position = UDim2.new(0, 4, 0, 4)
shapeList.BackgroundTransparency = 1
shapeList.BorderSizePixel = 0
shapeList.ScrollBarThickness = 4
shapeList.ScrollBarImageColor3 = Color3.fromRGB(90, 200, 255)
shapeList.AutomaticCanvasSize = Enum.AutomaticSize.Y
shapeList.CanvasSize = UDim2.new(0, 0, 0, 0)
shapeList.Parent = listFrame

local shapeLayout = Instance.new("UIListLayout")
shapeLayout.Padding = UDim.new(0, 2)
shapeLayout.Parent = shapeList

local shapeButtons = {}
local function refreshShapeButtons()
	for name, btn in pairs(shapeButtons) do
		local active = name == currentShape
		btn.BackgroundColor3 = active and Color3.fromRGB(40, 95, 180) or Color3.fromRGB(24, 24, 30)
		btn.TextColor3 = active and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 210)
	end
end

local rebuildShapeSettings

for index, name in ipairs(SHAPE_ORDER) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -4, 0, 24)
	btn.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
	btn.Text = name
	btn.TextColor3 = Color3.fromRGB(200, 200, 210)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 10
	btn.BorderSizePixel = 0
	btn.LayoutOrder = index
	btn.Parent = shapeList
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
	btn.MouseButton1Click:Connect(function()
		currentShape = name
		lastBlockCount = 0
		refreshShapeButtons()
		if rebuildShapeSettings then rebuildShapeSettings() end
	end)
	shapeButtons[name] = btn
end
refreshShapeButtons()

-- ---- Universal sliders ----
makeSectionHeader("TRANSFORM")
makeSlider(body, "Size", CFG.size, 0.3, 3.0, 0.05, function(v) CFG.size = v end, "Size")
makeSlider(body, "Speed", CFG.speed, 0, 4.0, 0.05, function(v) CFG.speed = v end, "Speed")
makeSlider(body, "Height", CFG.height, -20, 20, 0.5, function(v) CFG.height = v end, "Height")

local dirBtn = Instance.new("TextButton")
dirBtn.Size = UDim2.new(1, -8, 0, 22)
dirBtn.BackgroundColor3 = Color3.fromRGB(40, 95, 180)
dirBtn.Text = "DIRECTION: CW"
dirBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
dirBtn.Font = Enum.Font.GothamBold
dirBtn.TextSize = 10
dirBtn.BorderSizePixel = 0
dirBtn.LayoutOrder = nextOrder()
dirBtn.Parent = body
Instance.new("UICorner", dirBtn).CornerRadius = UDim.new(0, 5)
local function refreshDirBtn()
	dirBtn.Text = "DIRECTION: " .. (CFG.direction == 1 and "CW" or "CCW")
end
dirBtn.MouseButton1Click:Connect(function()
	CFG.direction = -CFG.direction
	refreshDirBtn()
end)

-- ---- Shape tuning ----
local tuningHeader = makeSectionHeader("TUNING")
local tuningContainer = Instance.new("Frame")
tuningContainer.Size = UDim2.new(1, -8, 0, 0)
tuningContainer.AutomaticSize = Enum.AutomaticSize.Y
tuningContainer.BackgroundTransparency = 1
tuningContainer.LayoutOrder = nextOrder()
tuningContainer.Parent = body

local tuningLayout = Instance.new("UIListLayout")
tuningLayout.Padding = UDim.new(0, 4)
tuningLayout.SortOrder = Enum.SortOrder.LayoutOrder
tuningLayout.Parent = tuningContainer

rebuildShapeSettings = function()
	for _, child in ipairs(tuningContainer:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end
	local shape = SHAPES[currentShape]
	if not shape or not shape.meta or next(shape.meta) == nil then
		tuningHeader.Visible = false
		return
	end
	tuningHeader.Visible = true
	local entries = {}
	for key, meta in pairs(shape.meta) do
		table.insert(entries, { key = key, meta = meta })
	end
	table.sort(entries, function(a, b) return a.meta.label < b.meta.label end)
	for idx, rec in ipairs(entries) do
		local container = makeSlider(
			tuningContainer,
			rec.meta.label,
			shape.settings[rec.key],
			rec.meta.min,
			rec.meta.max,
			rec.meta.step,
			function(v)
				shape.settings[rec.key] = v
				if rec.meta.onChange then rec.meta.onChange() end
			end
		)
		container.LayoutOrder = idx
	end
end
rebuildShapeSettings()

-- ---- RESET ----
local resetBtn = Instance.new("TextButton")
resetBtn.Size = UDim2.new(1, -8, 0, 26)
resetBtn.BackgroundColor3 = Color3.fromRGB(140, 90, 40)
resetBtn.Text = "RESET ALL SETTINGS"
resetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
resetBtn.Font = Enum.Font.GothamBold
resetBtn.TextSize = 10
resetBtn.BorderSizePixel = 0
resetBtn.LayoutOrder = nextOrder()
resetBtn.Parent = body
Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0, 6)

resetBtn.MouseButton1Click:Connect(function()
	for k, v in pairs(CFG_DEFAULTS) do CFG[k] = v end
	if UNIVERSAL_SETTERS.Size then UNIVERSAL_SETTERS.Size(CFG_DEFAULTS.size) end
	if UNIVERSAL_SETTERS.Speed then UNIVERSAL_SETTERS.Speed(CFG_DEFAULTS.speed) end
	if UNIVERSAL_SETTERS.Height then UNIVERSAL_SETTERS.Height(CFG_DEFAULTS.height) end
	refreshDirBtn()

	for _, shape in pairs(SHAPES) do
		for k, v in pairs(shape.defaults) do shape.settings[k] = v end
	end

	rebuildShapeSettings()
	assignLayers()

	print("[Shapes] All settings reset to defaults")
end)

-- ---- Collect / Release ----
local actionsContainer = Instance.new("Frame")
actionsContainer.Size = UDim2.new(1, -8, 0, 66)
actionsContainer.BackgroundTransparency = 1
actionsContainer.LayoutOrder = nextOrder()
actionsContainer.Parent = body

local collectBtn = Instance.new("TextButton")
collectBtn.Size = UDim2.new(1, 0, 0, 32)
collectBtn.Position = UDim2.new(0, 0, 0, 0)
collectBtn.BackgroundColor3 = Color3.fromRGB(40, 95, 180)
collectBtn.Text = "COLLECT BLOCKS"
collectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
collectBtn.Font = Enum.Font.GothamBold
collectBtn.TextSize = 11
collectBtn.BorderSizePixel = 0
collectBtn.Parent = actionsContainer
Instance.new("UICorner", collectBtn).CornerRadius = UDim.new(0, 6)

local releaseBtn = Instance.new("TextButton")
releaseBtn.Size = UDim2.new(1, 0, 0, 26)
releaseBtn.Position = UDim2.new(0, 0, 0, 38)
releaseBtn.BackgroundColor3 = Color3.fromRGB(140, 55, 55)
releaseBtn.Text = "RELEASE"
releaseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
releaseBtn.Font = Enum.Font.GothamBold
releaseBtn.TextSize = 10
releaseBtn.BorderSizePixel = 0
releaseBtn.Parent = actionsContainer
Instance.new("UICorner", releaseBtn).CornerRadius = UDim.new(0, 6)

collectBtn.MouseButton1Click:Connect(function()
	local count = collectBlocks()
	holding = count > 0
	collectBtn.Text = holding and (currentShape:upper() .. " (" .. count .. ")") or "NO BLOCKS"
	task.delay(2, function()
		if holding then collectBtn.Text = "COLLECT BLOCKS" end
	end)
end)

releaseBtn.MouseButton1Click:Connect(function()
	releaseBlocks()
	collectBtn.Text = "COLLECT BLOCKS"
end)

-- ---- Draggable window ----
do
	local dragging, dragStart, startPos
	local dragMoveConn, dragEndConn
	title.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
		end
	end)
	dragMoveConn = UIS.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)
	dragEndConn = UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	sg.Destroying:Connect(function()
		dragMoveConn:Disconnect()
		dragEndConn:Disconnect()
	end)
end

print("[Shapes] loaded — " .. #SHAPE_ORDER .. " patterns, rotation preserved, closable")