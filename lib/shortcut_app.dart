import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'shortcut.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class ShortcutApp extends StatefulWidget {
  const ShortcutApp({super.key});

  @override
  _ShortcutAppState createState() => _ShortcutAppState();
}

class _ShortcutAppState extends State<ShortcutApp> {
  List<Shortcut> shortcuts = [];
  List<Shortcut> filteredShortcuts = [];
  bool isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadShortcuts();
    _searchController.addListener(_filterShortcuts);
  }

  Future<void> _loadShortcuts() async {
    final directory = await getApplicationDocumentsDirectory();  // 获取应用文档目录
    final file = File('${directory.path}/data.json');  // 使用文档目录中的 data.json 文件

    if (await file.exists()) {
      // 读取文件内容
      final fileContents = await file.readAsString();
      final List<dynamic> shortcutJsonList = json.decode(fileContents);

      setState(() {
        // 将 JSON 字符串解析为 Shortcut 对象列表
        shortcuts = shortcutJsonList.map((shortcutJson) {
          final jsonMap = json.decode(shortcutJson);
          return Shortcut(
            name: jsonMap['name'],
            url: jsonMap['url'],
            iconPath: jsonMap['iconPath'],
            backgroundPath: jsonMap['backgroundPath'],
          );
        }).toList();
        filteredShortcuts = List.from(shortcuts);
      });
    } else {
      print('File does not exist');
    }
  }

  void _filterShortcuts() {
    String query = _searchController.text.toLowerCase().trim();
    print("Searching for: $query"); // 输出搜索的内容

    setState(() {
      filteredShortcuts = shortcuts.where((shortcut) {
        bool matchesName = shortcut.name.toLowerCase().contains(query);
        print("Matches for '${shortcut.name}': $matchesName"); // 输出每个快捷方式是否匹配
        return matchesName;
      }).toList();

      print('Filtered shortcuts: ${filteredShortcuts.map((s) => s.name).toList()}');
    });
  }




  Future<void> _saveShortcuts() async {
    //print('start to save...');
    final directory = await getApplicationDocumentsDirectory();  // 获取应用文档目录
    //print('document file:${directory.path}');
    final file = File('${directory.path}/data.json');  // 使用文档目录中的 data.json 文件

    // 将 shortcuts 列表转换为 JSON 字符串
    //print('the list to save:${shortcuts}');
    final shortcutJsonList = shortcuts.map((shortcut) {
      return json.encode({
        'name': shortcut.name,
        'url': shortcut.url,
        'iconPath': shortcut.iconPath ?? Shortcut.getDefaultIconPath(),
        'backgroundPath': shortcut.backgroundPath ?? Shortcut.getDefaultBackground(),
      });
    }).toList();
    //print('JSON list:${shortcutJsonList}');

    // 将 JSON 字符串列表写入文件
    await file.writeAsString(json.encode(shortcutJsonList));
    //print('save success!');
  }

  Future<void> _addShortcut(String name, String url, String? iconPath, String? backgroundPath) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/data.json');

    final newShortcut = Shortcut(
      name: name,
      url: url,
      iconPath: iconPath ?? Shortcut.getDefaultIconPath(),
      backgroundPath: backgroundPath ?? Shortcut.getDefaultBackground(),
    );

    final shortcutJson = json.encode({
      'name': newShortcut.name,
      'url': newShortcut.url,
      'iconPath': newShortcut.iconPath,
      'backgroundPath': newShortcut.backgroundPath,
    });

    setState(() {
      shortcuts.add(newShortcut);
      filteredShortcuts.add(newShortcut);  // 同时添加到过滤列表
    });

    final fileContents = await file.readAsString();
    final List<dynamic> existingShortcuts = json.decode(fileContents);
    existingShortcuts.add(shortcutJson);
    await file.writeAsString(json.encode(existingShortcuts));
  }


  void _deleteShortcut(int index) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/data.json');

    setState(() {
      shortcuts.removeAt(index);
      filteredShortcuts.removeAt(index);  // 从过滤列表中移除
    });

    final fileContents = await file.readAsString();
    final List<dynamic> existingShortcuts = json.decode(fileContents);
    existingShortcuts.removeAt(index);
    await file.writeAsString(json.encode(existingShortcuts));
  }

  void _editShortcut(int index) {
    String name = shortcuts[index].name;
    String url = shortcuts[index].url;
    String? iconPath = shortcuts[index].iconPath;
    String? backgroundPath = shortcuts[index].backgroundPath; // 添加背景图片路径变量
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit shortcuts'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                        initialValue: name,
                        validator: (value) => value == null || value.isEmpty ? 'Please enter a name' : null,
                        onChanged: (value) => name = value,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'URL', border: OutlineInputBorder()),
                        initialValue: url,
                        validator: (value) => value == null || value.isEmpty ? 'Please enter a URL' : null,
                        onChanged: (value) => url = value,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                                if (pickedFile != null) {
                                  setState(() {
                                    iconPath = pickedFile.path;
                                  });
                                }
                              },
                              child: const Text('Choose local icon'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(labelText: 'Icon path (available)', border: OutlineInputBorder()),
                              initialValue: iconPath ?? Shortcut.getDefaultIconPath(),
                              onChanged: (value) => iconPath = value,
                            ),
                          ),
                        ],
                      ),
                      if (iconPath != null) 
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0), 
                          child: Image(
                            image: FileImage(File(iconPath!)),
                            width: 150,
                            height: 150,
                          )
                        ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                                if (pickedFile != null) {
                                  setState(() {
                                    backgroundPath = pickedFile.path;
                                  });
                                }
                              },
                              child: const Text('Choose local background'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(labelText: 'Background path (available)', border: OutlineInputBorder()),
                              initialValue: backgroundPath ?? Shortcut.getDefaultBackground(),
                              onChanged: (value) => backgroundPath = value,
                            ),
                          ),
                        ],
                      ),
                      if (backgroundPath != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0), 
                          child: Image(image: FileImage(File(backgroundPath!)),
                          width: 150,
                          height: 150,
                        )
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(), 
                  child: const Text('Cancel')),
                TextButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      setState(() {
                        shortcuts[index] = Shortcut(
                          name: name, 
                          url: url, 
                          iconPath: iconPath, 
                          backgroundPath: backgroundPath,
                        );
                        _saveShortcuts();
                      });
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri url0 = Uri.parse(url);
    if (!await launchUrl(url0)) {
      throw Exception('Could not launch $url0');
    }
  }

  Widget _buildIcon(String? iconPath) {
    try {
      if (iconPath != null && iconPath.isNotEmpty) {
        return Image.file(File(iconPath), width: 40, height: 40);
      } else {
        return Image.asset(Shortcut.getDefaultIconPath(), width: 40, height: 40);
      }
    } catch (e) {
      print('Error loading image: $e');
      return const Icon(Icons.web, size: 40);
    }
  }

  ImageProvider _buildImageProvider(String? imagePath, String defaultImagePath) {
    if (imagePath != null) {
      return FileImage(File(imagePath));
    } else {
      return AssetImage(defaultImagePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: isSearching
        ? ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 35),
            child: TextField(
              controller: _searchController,
              style: TextStyle(fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Search shortcuts...',
                border: InputBorder.none,
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          )
        : Text(
          'Quick Browse Explore!',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            fontFamily: 'Pacifico',
            color: Colors.pink.shade200,
          ),
        ),
        elevation: 8,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.lightBlue, Colors.teal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          )
        ),
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.cancel : Icons.search),
            onPressed: () {
              setState(() {
                if (isSearching){
                  isSearching = false;
                  _searchController.clear();
                  filteredShortcuts = List.from(shortcuts);
                }
                else {
                  isSearching = true;
                }
              });
            },
          ),
          const SizedBox(width: 10,)
        ]
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 4.5,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: filteredShortcuts.length,
        itemBuilder: (context, index) {
          final shortcut = filteredShortcuts[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.all(8),
            child: Stack(
              children: [
                Container(
                  height: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: _buildImageProvider(shortcut.backgroundPath, Shortcut.getDefaultBackground()),
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                    ),
                  ),
                  child: InkWell(
                    onTap: () => _launchURL(shortcut.url),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: _buildIcon(shortcut.iconPath),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                shortcut.name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                shortcut.url,
                                style: const TextStyle(fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: PopupMenuButton<String>(
                    onSelected: (value){
                      switch(value){
                        case 'edit':
                          _editShortcut(index);
                          break;
                        case 'delete':
                          _deleteShortcut(index);
                          break;
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  )
                )
              ],
            )
          );
        },
      ),
      floatingActionButton: Stack(
        children: [
          // Add Shortcut Button
          Positioned(
            right: 0,
            bottom: 60,
            child: FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    String name = '';
                    String url = '';
                    String? selectedIconPath;
                    String? selectedBackgroundPath;
                    final formKey = GlobalKey<FormState>();

                    return StatefulBuilder(
                      builder: (context, setState) {
                        return AlertDialog(
                          title: const Text('Add shortcuts'),
                          content: SingleChildScrollView(
                            child: Form(
                              key: formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'Name',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a name';
                                      }
                                      return null;
                                    },
                                    onChanged: (value) => name = value,
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'URL',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a URL';
                                      }
                                      return null;
                                    },
                                    onChanged: (value) => url = value,
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                                            if (pickedFile != null) {
                                              setState(() {
                                                selectedIconPath = pickedFile.path;
                                              });
                                            }
                                          },
                                          child: const Text(
                                            'Choose local icon',
                                            style: TextStyle(fontSize: 20),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: TextFormField(
                                          decoration: const InputDecoration(
                                            labelText: 'Icon path (available)',
                                            border: OutlineInputBorder(),
                                          ),
                                          onChanged: (value) => selectedIconPath = value,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                                            if (pickedFile != null) {
                                              setState(() {
                                                selectedBackgroundPath = pickedFile.path;
                                              });
                                            }
                                          },
                                          child: const Text(
                                            'Choose local background',
                                            style: TextStyle(fontSize: 20),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: TextFormField(
                                          decoration: const InputDecoration(
                                            labelText: 'Background path (available)',
                                            border: OutlineInputBorder(),
                                          ),
                                          onChanged: (value) => selectedBackgroundPath = value,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (selectedIconPath != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Image(image: FileImage(File(selectedIconPath!))),
                                    ),
                                  if (selectedBackgroundPath != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Image(image: FileImage(File(selectedBackgroundPath!))),
                                    )
                                ],
                              ),
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  _addShortcut(name, url, selectedIconPath, selectedBackgroundPath);
                                  Navigator.of(context).pop();
                                }
                              },
                              child: const Text(
                                'Add',
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
              tooltip: 'Add Shortcut',
              child: const Icon(Icons.add),
            ),
          ),
          // Refresh Button
          Positioned(
            right: 0,
            bottom: 0,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  // Force UI refresh by calling setState
                  filteredShortcuts = List.from(shortcuts);
                });
              },
              backgroundColor: Colors.blue,
              child: const Icon(Icons.refresh),
            ),
          ),
        ],
      ),
    );
  }
}