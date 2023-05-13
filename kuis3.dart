import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;

class DetailPinjaman {
  String id;
  String nama;
  String bunga;
  String syariah;
  DetailPinjaman(
      {required this.id,
      required this.nama,
      required this.bunga,
      required this.syariah});
}

class Pinjaman {
  String id;
  String nama;
  Pinjaman({required this.id, required this.nama});
}

class ListPinjamanModel {
  List<Pinjaman> listPinjamanModel = <Pinjaman>[];
  ListPinjamanModel({required this.listPinjamanModel});
}

class ListPinjamanCubit extends Cubit<ListPinjamanModel> {
  String selectedId = "1";

  ListPinjamanCubit() : super(ListPinjamanModel(listPinjamanModel: [])) {
    fetchData();
  }

  void setId(String id) {
    selectedId = id;
    fetchData();
  }

  void setFromJson(Map<String, dynamic> json) {
    var data = json["data"];
    List<Pinjaman> listPinjamanModel = <Pinjaman>[];
    for (var val in data) {
      var id = val["id"];
      var nama = val["nama"];
      listPinjamanModel.add(Pinjaman(id: id, nama: nama));
    }
    emit(ListPinjamanModel(listPinjamanModel: listPinjamanModel));
  }

  void fetchData() async {
    String url = "http://178.128.17.76:8000/jenis_pinjaman/$selectedId";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      setFromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal load');
    }
  }
}

class DetailPinjamanCubit extends Cubit<DetailPinjaman> {
  String id = "";

  DetailPinjamanCubit()
      : super(DetailPinjaman(id: "", nama: "", bunga: "", syariah: "")) {
    fetchData(id);
  }

  //map dari json ke atribut
  void setFromJson(Map<String, dynamic> json) {
    String nama = json["nama"];
    String bunga = json["bunga"];
    String syariah = json["is_syariah"];
    emit(DetailPinjaman(id: id, nama: nama, bunga: bunga, syariah: syariah));
  }

  void fetchData(String id) async {
    this.id = id;
    String url = "http://178.128.17.76:8000/detil_jenis_pinjaman/$id";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setFromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal load');
    }
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: MultiBlocProvider(
      providers: [
        BlocProvider<ListPinjamanCubit>(
          create: (BuildContext context) => ListPinjamanCubit(),
        ),
        BlocProvider<DetailPinjamanCubit>(
          create: (BuildContext context) => DetailPinjamanCubit(),
        ),
      ],
      child: HalamanUtama(),
    ));
  }
}

class LayarKedua extends StatefulWidget {
  LayarKedua({Key? key, required this.pesan}) : super(key: key);
  final String pesan;

  @override
  _LayarKeduaState createState() => _LayarKeduaState();
}

class _LayarKeduaState extends State<LayarKedua> {
  @override
  void initState() {
    super.initState();
    context.read<DetailPinjamanCubit>().fetchData(widget.pesan);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pinjaman'),
      ),
      body: Center(
        child: BlocBuilder<DetailPinjamanCubit, DetailPinjaman>(
          builder: (context, model) {
            if (model.id.isNotEmpty) {
              return Container(
                height: 200,
                decoration: BoxDecoration(
                    color: Color.fromARGB(255, 192, 224, 231),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all()),
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Id: ${model.id}"),
                    Text("Nama: ${model.nama}"),
                    Text("Bunga: ${model.bunga}"),
                    Text("Syariah: ${model.syariah}"),
                  ],
                ),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}

class HalamanUtama extends StatelessWidget {
  HalamanUtama({Key? key}) : super(key: key);

  final List<DropdownMenuItem<String>> countries = [
    const DropdownMenuItem<String>(
      value: "1",
      child: Text("Jenis pinjaman 1"),
    ),
    const DropdownMenuItem<String>(
      value: "2",
      child: Text("Jenis pinjaman 2"),
    ),
    const DropdownMenuItem<String>(
      value: "3",
      child: Text("Jenis pinjaman 3"),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App P2P',
      home: Scaffold(
        appBar: AppBar(
          title: const Center(child: Text('My App P2P')),
        ),
        body: Column(
          children: [
            Container(
                padding: EdgeInsets.all(20),
                child: const Text(
                  '2100901, Azzahra Siti Hadjar; 2102843, Najma Qalbi Dwiharani; Saya berjanji tidak akan berbuat curang data atau membantu orang lain berbuat curang',
                )),
            BlocBuilder<ListPinjamanCubit, ListPinjamanModel>(
              buildWhen: (previousState, state) {
                developer.log(
                  "${previousState.listPinjamanModel} -> ${state.listPinjamanModel}",
                  name: 'logkel7',
                );
                return true;
              },
              builder: (context, model) {
                return DropdownButton<String>(
                  value: context.watch<ListPinjamanCubit>().selectedId,
                  onChanged: (String? newValue) {
                    context.read<ListPinjamanCubit>().setId(newValue!);
                  },
                  items: countries,
                );
              },
            ),
            Expanded(
              child: BlocBuilder<ListPinjamanCubit, ListPinjamanModel>(
                builder: (context, model) {
                  if (model.listPinjamanModel.isNotEmpty) {
                    return ListView.builder(
                      itemCount: model.listPinjamanModel.length,
                      itemBuilder: (context, index) {
                        return Card(
                            child: ListTile(
                          onTap: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return LayarKedua(
                                  pesan: model.listPinjamanModel[index].id);
                            }));
                          },
                          leading: Image.network(
                              'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg'),
                          trailing: const Icon(Icons.more_vert),
                          title: Text(model.listPinjamanModel[index].nama),
                          subtitle:
                              Text("Id: ${model.listPinjamanModel[index].id}"),
                          tileColor: Colors.white70,
                        ));
                      },
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
