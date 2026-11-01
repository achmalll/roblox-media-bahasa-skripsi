-- Pure factory embedded in the existing LevelProgressHandler by build-recording.cjs.
return function(deps)
 local self={levels={},pages={},page=1,sequence=0,seen={},closed=false,saving=false,status="pending",droppedEvents=0}
 local function copy(v)
  if type(v)~="table" then return v end
  local out={}; for k,x in pairs(v) do out[k]=copy(x) end; return out
 end
 local function current()
  if not self.pages[self.page] then self.pages[self.page]={events={},revision=0} end
  return self.pages[self.page]
 end
 local function dirty()
  current().revision+=1; self.persistedClean=false
  self.status=self.droppedEvents>0 and "incomplete" or "pending"
 end
 local function updateTimes()
  for _,level in pairs(self.levels) do
   if not level.completed then level.observedSeconds=math.max(0,deps.now()-level.clock) end
  end
 end
 local function snapshot(index,page)
  updateTimes()
  local levels=copy(self.levels); for _,v in pairs(levels) do v.clock=nil end
  return {schemaVersion=1,contentRevision=deps.contentRevision,userId=deps.userId,sessionId=deps.sessionId,
   placeId=deps.placeId,jobId=deps.jobId,page=index,revision=page.revision,
   sessionStartedAtMs=deps.startedAtMs,savedAtMs=deps.utc(),sessionClosed=self.closed,closeReason=self.closeReason,
   levels=levels,events=copy(page.events),droppedEvents=self.droppedEvents,
   timingDefinition="session_elapsed_until_first_pass"}
 end
 function self:start(level,quality)
  if self.closed or self.levels[tostring(level)] then return end
  self.levels[tostring(level)]={startedAtMs=deps.utc(),clock=deps.now(),observedSeconds=0,
   timingQuality=quality or "first_interaction",completed=false}
  dirty()
 end
 function self:append(level,kind,data,id)
  if self.closed or (id and self.seen[id]) then return false end
  local pending=0; for _,p in pairs(self.pages) do pending+=#p.events end
  if pending>=4096 then
   self.droppedEvents+=1; dirty()
   if self.droppedEvents==1 then deps.warn("Unflushed buffer full; recording incomplete; storage requires attention") end
   return false
  end
  if #current().events>=64 then self.page+=1 end
  self:start(level,kind=="evaluation" and "evaluation_only" or "first_observed_activity")
  self.sequence+=1
  table.insert(current().events,{sequence=self.sequence,atMs=deps.utc(),level=level,kind=kind,data=copy(data),
   elapsedSeconds=math.max(0,deps.now()-self.levels[tostring(level)].clock)})
  if id then self.seen[id]=true end
  dirty(); return true
 end
 function self:result(level,payload,score,reasons)
  if not self:append(level,"evaluation",{attemptId=payload.id,answers=payload.answers,reasons=payload.reasons,
   score=score,reasonCorrect=reasons,validation="server_choices"},"result:"..level..":"..payload.id) then return false end
  local t=self.levels[tostring(level)]; t.bestScore=math.max(t.bestScore or 0,score)
  if score>=75 and not t.completed then
   t.observedSeconds=math.max(0,deps.now()-t.clock); t.completed=true; t.completedAtMs=deps.utc()
   if t.timingQuality~="evaluation_only" then t.completedSeconds=t.observedSeconds end
  end
  dirty(); return true
 end
 function self:checkpoint() if not self.closed then updateTimes(); dirty() end end
 function self:close(reason)
  if self.closed then return end
  updateTimes(); self.closed=true; self.closeReason=reason; dirty()
 end
 function self:flush()
  if self.saving then return false end
  self.saving=true
  local indexes={}; for i in pairs(self.pages) do table.insert(indexes,i) end; table.sort(indexes)
  local ok=true
  for _,index in ipairs(indexes) do
   local p=self.pages[index]
   if p.savedRevision~=p.revision then
    local version=p.revision; local data=snapshot(index,p); local success=false
    for retry=1,3 do
     success=pcall(deps.write,string.format("%s:%06d",deps.sessionId,index),data)
     if success then break end
     deps.wait(retry)
    end
    if success then
     p.savedRevision=version
     if index<self.page and p.revision==version then self.pages[index]=nil end
    else ok=false; deps.warn("DataStore save failed; records retained for retry") end
   end
  end
  self.saving=false
  local clean=ok; for _,p in pairs(self.pages) do if p.savedRevision~=p.revision then clean=false end end
  self.persistedClean=clean
  self.status=clean and (self.droppedEvents>0 and "incomplete" or "saved") or (ok and "pending" or "failed")
  return clean
 end
 return self
end
