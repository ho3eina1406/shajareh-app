import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
const green=Color(0xFF174C3C);
void main()=>runApp(const MaterialApp(debugShowCheckedModeBanner:false,theme:ThemeData(useMaterial3:true,colorScheme:ColorScheme.fromSeed(seedColor:green)),home:Directionality(textDirection:TextDirection.rtl,child:TreeApp())));
class TreeApp extends StatefulWidget{const TreeApp({super.key});@override State<TreeApp> createState()=>_TreeAppState();}
class TreeAppStateX{}
class _TreeAppState extends State<TreeApp>{
 List<Map<String,String>> people=[];bool busy=true;
 @override void initState(){super.initState();load();}
 Future<void> load()async{final p=await SharedPreferences.getInstance();final v=jsonDecode(p.getString('tree')??'[]') as List;setState(()=>{people=v.map((e)=>Map<String,String>.from(e)).toList(),busy=false});}
 Future<void> save()async{final p=await SharedPreferences.getInstance();await p.setString('tree',jsonEncode(people));}
 Future<void> add()async{
 final name=TextEditingController(),birth=TextEditingController();String? father,mother;
 final ok=await showDialog<bool>(context:context,builder:(c)=>StatefulBuilder(builder:(c,s)=>AlertDialog(title:const Text('افزودن فرد به شجره'),content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
 TextField(controller:name,decoration:const InputDecoration(labelText:'نام و نام خانوادگی *')),
 TextField(controller:birth,decoration:const InputDecoration(labelText:'سال تولد (اختیاری)')),
 DropdownButtonFormField<String?>(value:father,decoration:const InputDecoration(labelText:'پدر'),items:[const DropdownMenuItem<String?>(value:null,child:Text('ثبت نشده')),...people.map((p)=>DropdownMenuItem<String?>(value:p['id'],child:Text(p['name']!)))],onChanged:(v)=>s(()=>father=v)),
 DropdownButtonFormField<String?>(value:mother,decoration:const InputDecoration(labelText:'مادر'),items:[const DropdownMenuItem<String?>(value:null,child:Text('ثبت نشده')),...people.map((p)=>DropdownMenuItem<String?>(value:p['id'],child:Text(p['name']!)))],onChanged:(v)=>s(()=>mother=v))
 ])),actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('لغو')),FilledButton(onPressed:()=>Navigator.pop(c,true),child:const Text('ذخیره'))])));
 if(ok==true&&name.text.trim().isNotEmpty){setState(()=>people.add({'id':DateTime.now().microsecondsSinceEpoch.toString(),'name':name.text.trim(),'birth':birth.text.trim(),'father':father??'','mother':mother??''}));await save();}
 }
 String person(String id)=>people.firstWhere((p)=>p['id']==id,orElse:()=>{'name':''})['name']!;
 @override Widget build(BuildContext c)=>Scaffold(appBar:AppBar(title:const Text('شجره‌نامه خانواده'),backgroundColor:green,foregroundColor:Colors.white),floatingActionButton:FloatingActionButton.extended(onPressed:add,backgroundColor:green,foregroundColor:Colors.white,icon:const Icon(Icons.add),label:const Text('افزودن فرد')),body:busy?const Center(child:CircularProgressIndicator()):people.isEmpty?const Center(child:Padding(padding:EdgeInsets.all(28),child:Text('برای شروع، بزرگ‌ترهای خانواده را ثبت کن. سپس هنگام افزودن فرزندان، پدر و مادرشان را انتخاب کن.',textAlign:TextAlign.center,style:TextStyle(fontSize:17,height:1.8)))):ListView(padding:const EdgeInsets.all(14),children:[Card(child:ListTile(leading:const Icon(Icons.people,color:green),title:Text('تعداد افراد: '+people.length.toString()))),...people.map((p)=>Card(child:ListTile(leading:const CircleAvatar(child:Icon(Icons.person)),title:Text(p['name']!),subtitle:Text([if(p['birth']!.isNotEmpty)'تولد: '+p['birth']!,if(p['father']!.isNotEmpty)'پدر: '+person(p['father']!),if(p['mother']!.isNotEmpty)'مادر: '+person(p['mother']!)].join(' • '))))),const Padding(padding:EdgeInsets.all(12),child:Text('اطلاعات روی همین گوشی ذخیره می‌شود؛ هنوز همگام‌سازی اینترنتی ندارد.',style:TextStyle(color:Colors.black54))) ]));
 }
}