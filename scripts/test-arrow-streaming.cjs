// Run the actual arrow script with every legacy Workspace target streamed out.
const fs = require('node:fs'), cp = require('node:child_process'), path = require('node:path');
const root = path.resolve(__dirname, '..');
const mock = `
local frame, change, spawn, pointed, openGui, hide
local rootPresent=true
local vmt={}
vmt.__index=function(t,k) if k=="Magnitude" then return math.sqrt(t.X*t.X+t.Y*t.Y+t.Z*t.Z) end end
vmt.__sub=function(a,b) return Vector3.new(a.X-b.X,a.Y-b.Y,a.Z-b.Z) end
Vector3={new=function(x,y,z) return setmetatable({X=x,Y=y,Z=z},vmt) end}
CFrame={new=function(a,b) return {a,b} end}
local progress={Value=2,Changed={Connect=function(_,f) change=f end}}
local attrs={L2GuideTarget=Vector3.new(20,0,0)}
local char={FindFirstChild=function() if rootPresent then return {Position=Vector3.new(0,0,0)} end end}
local player={Character=char,CharacterAdded={Connect=function(_,f) spawn=f end},PlayerGui={FindFirstChild=function(_,name)
 if name==openGui then return {Enabled=true,GetChildren=function() return {{Name="Panel",Visible=true,IsA=function() return true end}} end} end
end}}
function player:GetAttribute(k) return attrs[k] end
function player:WaitForChild(n) assert(n=="leaderstats"); return {WaitForChild=function(_,k) assert(k=="LevelProgress"); return progress end} end
local body={IsA=function() return true end}
local arrow={Arrow=body}
function arrow:GetDescendants() return {body} end
function arrow:SetPrimaryPartCFrame(cf) assert(not self.Destroyed,"Destroyed arrow must not be rendered"); pointed=cf[2] end
function arrow:Destroy() self.Destroyed=true end
local rs={RenderStepped={Connect=function(_,f) frame=f end}}
local rep={WaitForChild=function(_,n) if n=="ArrowModel" then return {Clone=function() arrow.Destroyed=false; return arrow end} end; assert(n=="HideArrowEvent"); return {Event={Connect=function(_,f) hide=f end}} end}
workspace={FindFirstChild=function() return nil end,WaitForChild=function() error("Must not wait for distant Workspace targets") end}
game={Players={LocalPlayer=player},GetService=function(_,n) if n=="RunService" then return rs end; assert(n=="ReplicatedStorage"); return rep end}
`;
const assertions = `
assert(frame and change and spawn)
frame(); assert(pointed.X==20)
attrs.L2LearningOpen=true; pointed=nil; frame(); assert(pointed==nil)
attrs.L2LearningOpen=nil; attrs.L2GuideTarget=nil; frame(); assert(pointed==nil)
spawn(char); attrs.L2GuideTarget=Vector3.new(30,0,0); frame(); assert(pointed.X==30)
progress.Value=1; attrs.L1GuideTarget=Vector3.new(10,0,0); change(); frame(); assert(pointed.X==10)
for _,name in ipairs({"Level1Gui","FlowGui","Welcome GUI","Level3Gui","Level3Board"}) do
 openGui=name; frame(); assert(body.LocalTransparencyModifier==1,"Arrow must hide for "..name)
end
openGui=nil; frame(); assert(body.LocalTransparencyModifier==0)
rootPresent=false; frame(); assert(body.LocalTransparencyModifier==1,"Missing character root must hide old arrow")
rootPresent=true; spawn(char); frame(); assert(body.LocalTransparencyModifier==0)
hide(); pointed=nil; frame(); assert(pointed==nil)
spawn(char); frame(); assert(pointed.X==10)
print("PASS arrow: streaming, L1/L2 targets, all panels including L3, missing root, respawn, destroyed-arrow cleanup")
`;
const target = path.join(root, 'local-rbxl/bridge/test-arrow-streaming.luau');
fs.mkdirSync(path.dirname(target), {recursive: true});
fs.writeFileSync(target, mock + '\n' + fs.readFileSync(path.join(root, 'studio-sync/src/ArrowGuideScript.client.luau'), 'utf8') + '\n' + assertions);
process.stdout.write(cp.execFileSync(path.join(root, 'local-rbxl/luau-0.745/luau.exe'), [target], {encoding: 'utf8'}));
