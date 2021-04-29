import 'package:http/http.dart' as http;

import 'dart:convert';
import 'dart:async';

import 'package:peliculas/src/models/pelicula_model.dart';
import 'package:peliculas/src/models/actores_model.dart';





class PeliculasProvider{
  String _apiKey = '8ae62157bb76d543f9ed7caf3d34d28d';
  String _url = 'api.themoviedb.org';
  String _language = 'es-Es';
  
  int _popularesPage = 0;
  bool _cargando = false;

  List<Pelicula> _populares = new List();

  final _popularesStreamController = StreamController<List<Pelicula>>.broadcast();


  Function(List<Pelicula>) get popularesSink => _popularesStreamController.sink.add;
  
  Stream<List<Pelicula>> get popularesStream => _popularesStreamController.stream;



  void disposeStreams() {   
    _popularesStreamController?.close();

  }


  Future<List<Pelicula>> getEncines() async {
    final url = Uri.https(_url, '3/movie/now_playing', {
      'api_key' : _apiKey,
      'language': _language
    });


    final respuesta = await http.get(url);

    final decodedData = json.decode(respuesta.body);
    final peliculas = new Peliculas.fromJsonList(decodedData['results']);

    // print(peliculas.items[0]);


    return peliculas.items;
  }
  
  Future<List<Pelicula>> getPopulares() async {
    
    
    if(_cargando) return [];

    _cargando = true;     
    
    ++_popularesPage;

    ///movie/popular
    final url = Uri.https(_url, '3/movie/popular',{
      'api_key' : _apiKey,
      'language': _language,
      'page'    : _popularesPage.toString()
    });

    final respuesta = await http.get(url);

    final decodedData = json.decode(respuesta.body);
    final peliculas = new Peliculas.fromJsonList(decodedData['results']);
    // print(peliculas.items[0].title);

    final resp = peliculas.items;

    _populares.addAll(resp);

    popularesSink(_populares);
    
    _cargando = false;
    
    return resp;
  }

  Future<List<Actor>> getCast( String peliId ) async{
    final url = Uri.https(_url, '3/movie/$peliId/credits',{
      'api_key' : _apiKey,
      'language': _language
    });

    final resp = await http.get(url);
    final decodedData = json.decode(resp.body);
    
    final cast = new Cast.fromJsonList(decodedData['cast']);

    return cast.actores;


  }

  Future<List<Pelicula>> buscarPelicula(String query) async {



    final url = Uri.https(_url, '3/search/movie', {
      'api_key' : _apiKey,
      'language': _language,
      'query'   : query,
    });


    final respuesta = await http.get(url);

    final decodedData = json.decode(respuesta.body);
    final peliculas = new Peliculas.fromJsonList(decodedData['results']);

    // print(peliculas.items[0]);


    return peliculas.items;
  }


}