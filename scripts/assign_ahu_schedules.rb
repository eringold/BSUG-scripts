require 'openstudio'
require_relative '../setup.rb'
require_relative '../lib/model.rb'


# load model
osm_path = File.join(@osm_dir, @osm_name)
model = ModelFile.load_model(osm_path)

#### save a backup
backup = ModelFile.unique_name(osm_path)
model.save_model(File.basename(backup),@osm_dir)

#### do stuff here


avail_sch_name = "Fan Schedule"

oa_sch_name = "Fan Schedule"

avail_sch = model.getScheduleByName(avail_sch_name)
if avail_sch.is_initialized
  avail_sch = avail_sch.get
else puts "CANNOT FIND AVAILABILITY SCHEDULE WITH THAT NAME"
  exit # this stops the script
end 


oa_sch = model.getScheduleByName(oa_sch_name)
if oa_sch.is_initialized
  oa_sch = oa_sch.get
else puts "CANNOT FIND OUTDOOR AIR SCHEDULE WITH THAT NAME"
  exit # this stops the script
end 

model.getAirLoopHVACs.each do |ahu|
  ahu.setAvailabilitySchedule(avail_sch)
  ahu.setNightCycleControlType("CycleOnAny")
  ahu.supplyComponents.each do |comp|
    if comp.to_AirLoopHVACOutdoorAirSystem.is_initialized
      comp = comp.to_AirLoopHVACOutdoorAirSystem.get
      controller = comp.getControllerOutdoorAir
      controller.setMinimumOutdoorAirSchedule(oa_sch)
    end 
  end 
end












### save model
model.save_model(@osm_name,@osm_dir)