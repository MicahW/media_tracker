# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.create(name: "demo", password: "demo")
User.create(name: "demo2", password: "demo2")

extlist = ["a","b","c","d","e","f","g","h","i","j","k"];
dagr_list = []
user = User.where(name: "demo").take
user2 = User.where(name: "demo2").take

extlist.each do |ext|
  dagr = Dagr.add_dagr(user,"file_" + ext + ".demo","home/demo/hierachy",1,ext,nil)
  dagr_list.push(dagr)
end

  #def self.add_relationship(user,parent,child)

relas = [[0,1],[1,2],[1,3],[2,6],[2,7],[3,7],[4,5],[4,1],[5,10],[6,8],[6,9],[7,10]]
relas.each do |rel|
  Belong.add_relationship(user,dagr_list[rel[0]],dagr_list[rel[1]])
end

created_days = ["1","2","3","4","5"]

created_days.each do |day|
  dagr = Dagr.add_dagr(user,"time_demo_" + day,"/demo",0,nil,nil)
  date = "2017-12-"+day+ " 12:00:01"
  dagr.update_attribute("created_at", date)
  has = UserHas.where(dagrs_guid: dagr.guid, users_id: user.id).take
  has.update_attribute("created_at", date)
  dagr = Dagr.add_dagr(user2,"time_demo_" + day,"/demo",0,nil,nil)
end


keywords = ["a,b,c","b,c,d","a","c,e","b","c,d"]
names = ["alpha","beta","any","one","can"]
(0..4).each do |i|
  dagr = Dagr.add_dagr(user,"file_" + names[i] + ".key","home/demo/hierachy",1,nil,keywords[i])
end
  




