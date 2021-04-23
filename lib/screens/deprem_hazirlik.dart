import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class DepremHazirlik extends StatefulWidget {
  @override
  _DepremHazirlik createState() => _DepremHazirlik();
}

class _DepremHazirlik extends State<DepremHazirlik>
    with SingleTickerProviderStateMixin {
  TabController _controller;

  List<Widget> tabHeaders = [
    Tab(
      icon: Icon(Icons.warning),
      text: "Anında",
    ),
    Tab(
      icon: Icon(Icons.help),
      text: "Sonrasında",
    ),
    Tab(
      icon: Icon(Icons.home_repair_service_rounded),
      text: "Çantası",
    )
  ];

  List<bool> bagItemsChecked = new List<bool>(13);
  List<String> savedBagItemsChecked = new List<String>(13);

  //save checked items
  setPref() async {
    for (int i = 0; i < 13; i++) {
      if (bagItemsChecked[i])
        savedBagItemsChecked[i] = "1";
      else
        savedBagItemsChecked[i] = "0";
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList("checkedItems", savedBagItemsChecked);
  }

  //get latest list if exist
  getPref() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    savedBagItemsChecked =
        prefs.getStringList("checkedItems") ?? defaultCheckList();

    setState(() {
      for (int i = 0; i < 13; i++) {
        if (savedBagItemsChecked[i] == "1")
          bagItemsChecked[i] = true;
        else
          bagItemsChecked[i] = false;
      }
    });
  }

  defaultCheckList() {
    List<String> temp = new List<String>(13);
    temp.fillRange(0, 13, "0");
    return temp;
  }

  @override
  void initState() {
    super.initState();
    // Create TabController for getting the index of current tab
    _controller = TabController(length: tabHeaders.length, vsync: this);
    bagItemsChecked.fillRange(0, 13, false); // default list
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Ubuntu',
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            controller: _controller,
            tabs: tabHeaders,
          ),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Route route = MaterialPageRoute(
                    builder: (context) => MyHomePage(
                          title: "Deprem Acil Yardım",
                        ));
                Navigator.pushReplacement(context, route);
              }),
          title: Text('Deprem'),
        ),
        body: TabBarView(
          controller: _controller,
          children: [
            //first tab
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "BİNA İÇERİSİNDEYSENİZ\n",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 23),
                    ),
                    Text(
                      "Kesinlikle panik yapılmamalıdır.\n\n" +
                          "Sabitlenmemiş dolap, raf, pencere vb. eşyalardan uzak durulmalıdır.\n\n" +
                          "Varsa sağlam sandalyelerle desteklenmiş masa altına veya dolgun ve hacimli koltuk, kanepe, içi dolu sandık gibi koruma sağlayabilecek eşya yanına çömelerek hayat üçgeni oluşturulmalıdır.\nBaş iki el arasına alınarak veya bir koruyucu (yastık, kitap vb) malzeme ile korunmalıdır. Sarsıntı geçene kadar bu pozisyonda beklenmelidir.\n\n" +
                          "Güvenli bir yer bulup, diz üstü ÇÖK, Başını ve enseni koruyacak şekilde KAPAN, Düşmemek için sabit bir yere TUTUN\nMerdivenlere ya da çıkışlara doğru koşulmamalıdır.\nBalkona çıkılmamalıdır.\n\n" +
                          "Balkonlardan ya da pencerelerden aşağıya atlanmamalıdır.\nKesinlikle asansör kullanılmamalıdır.\nTelefonlar acil durum ve yangınları bildirmek dışında kullanılmamalıdır." +
                          "Kibrit, çakmak yakılmamalı, elektrik düğmelerine dokunulmamalıdır.\nTekerlekli sandalyede isek tekerlekler kilitlenerek baş ve boyun korumaya alınmalıdır.\n\n" +
                          "Mutfak, imalathane, laboratuvar gibi iş aletlerinin bulunduğu yerlerde; ocak, fırın ve bu gibi cihazlar kapatılmalı, dökülebilecek malzeme ve maddelerden uzaklaşılmalıdır.\n\n" +
                          "Sarsıntı geçtikten sonra elektrik, gaz ve su vanalarını kapatılmalı, soba ve ısıtıcılar söndürülmelidir.\n\n" +
                          "Diğer güvenlik önlemleri alınarak gerekli olan eşya ve malzemeler alınarak bina daha önce tespit edilen yoldan derhal terk edilip toplanma bölgesine gidilmelidir.\n\n" +
                          "Okulda sınıfta ya da büroda ise sağlam sıra, masa altlarında veya yanında; koridorda ise duvarın yanına hayat üçgeni oluşturacak şekilde ÇÖK-KAPAN-TUTUN hareketi ile baş ve boyun korunmalıdır.\n\n" +
                          "Pencerelerden ve camdan yapılmış eşyalardan uzak durulmalıdır.\n\n",
                      textAlign: TextAlign.justify,
                      style: TextStyle(fontSize: 20),
                    ),
                    Text(
                      "DEPREM ANINDA AÇIK ALANDAYSANIZ\n",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 23),
                    ),
                    Text(
                      "Enerji hatları ve direklerinden, ağaçlardan, diğer binalardan ve duvar diplerinden uzaklaşılmalıdır. Açık arazide çömelerek etraftan gelen tehlikelere karşı hazırlıklı olunmalıdır.\nToprak kayması olabilecek, taş veya kaya düşebilecek yamaç altlarında bulunulmamalıdır. Böyle bir ortamda bulunuluyorsa seri şekilde güvenli bir ortama geçilmelidir.\n\n" +
                          "Binalardan düşebilecek baca, cam kırıkları ve sıvalara karşı tedbirli olunmalıdır.\n\n" +
                          "Varsa sağlam sandalyelerle desteklenmiş masa altına veya dolgun ve hacimli koltuk, kanepe, içi dolu sandık gibi koruma sağlayabilecek eşya yanına çömelerek hayat üçgeni oluşturulmalıdır.\nBaş iki el arasına alınarak veya bir koruyucu (yastık, kitap vb) malzeme ile korunmalıdır. Sarsıntı geçene kadar bu pozisyonda beklenmelidir.\n\n" +
                          "Toprak altındaki kanalizasyon, elektrik ve gaz hatlarından gelecek tehlikelere karşı dikkatli olunmalıdır.\n\n" +
                          "Balkonlardan ya da pencerelerden aşağıya atlanmamalıdır.\nKesinlikle asansör kullanılmamalıdır.\nTelefonlar acil durum ve yangınları bildirmek dışında kullanılmamalıdır." +
                          "Deniz kıyısından uzaklaşılmalıdır.\n\n",
                      textAlign: TextAlign.justify,
                      style: TextStyle(fontSize: 20),
                    ),
                    Text(
                      "DEPREM ANINDA ARAÇ KULLANIYORSANIZ\n",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 23),
                    ),
                    Text(
                      "Sarsıntı sırasında karayolunda seyir halindeyseniz;\n- Bulunduğunuz yer güvenli ise; yolu kapatmadan sağa yanaşıp durulmalıdır. Kontak anahtarı yerinde bırakılıp, pencereler kapalı olarak araç içerisinde beklenmelidir. Sarsıntı durduktan sonra açık alanlara gidilmelidir.\n\n" +
                          "- Araç meskun mahallerde ya da güvenli bir yerde değilse (ağaç ya da enerji hatları veya direklerinin yanında, köprü üstünde vb.); durdurulmalı, kontak anahtarı üzerinde bırakılarak terk edilmeli ve trafikten uzak açık alanlara gidilmelidir.\n\n" +
                          "Sarsıntı sırasında bir tünelin içindeyseniz ve çıkışa yakın değilseniz; araç durdurulup aşağıya inilmeli ve yanına yan yatarak ayaklar karına çekilip, ellerle baş ve boyun korunmalıdır. (ÇÖK-KAPAN-TUTUN)\n\n" +
                          "Kapalı bir otoparkta iseniz; araç dışına çıkılıp, yanına yan yatarak, ellerle baş ve boyun korunmalıdır. Yukarıdan düşebilecek tavan, tünel gibi büyük kitleler aracı belki ezecek ama yok etmeyecektir. Araç içinde olduğunuz takdirde, aracın üzerine düşen bir parça ile aracın içinde ezilebilirsiniz.\n\n",
                      textAlign: TextAlign.justify,
                      style: TextStyle(fontSize: 20),
                    ),
                    Text(
                      "METRODA VEYA DİĞER TOPLU TAŞIMA ARAÇLARINDAYSANIZ\n",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 23),
                    ),
                    Text(
                      "Gerekmedikçe, kesinlikle metro ve trenden inilmemelidir. Elektriğe kapılabilirsiniz veya diğer hattan gelen başka bir metro yada tren size çarpabilir.\n\n" +
                          "Sarsıntı bitinceye kadar metro ya da trenin içinde, sıkıca tutturulmuş askı, korkuluk veya herhangi bir yere tutunmalı, metro veya tren personeli tarafından verilen talimatlara uyulmalıdır.\n\n",
                      textAlign: TextAlign.justify,
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
            ),
            //second tab
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "KAPALI ALANDAYSANIZ\n",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 23),
                    ),
                    Text(
                      "Önce kendi emniyetinizden emin olun.\nSonra çevrenizde yardım edebileceğiniz kimse olup olmadığını kontrol edin.\n\n" +
                          "Depremlerden sonra çıkan yangınlar oldukça sık görülen ikincil afetlerdir. Bu nedenle eğer gaz kokusu alırsanız, gaz vanasını kapatın. Camları ve kapıları açın. Hemen binayı terk edin.\nDökülen tehlikeli maddeleri temizleyin.\n\n" +
                          "Yerinden oynayan telefon ahizelerini telefonun üstüne koyun.\nAcil durum çantanızı yanınıza alın, mahalle buluşma noktanıza doğru harekete geçin.\n\n" +
                          "Radyo ve televizyon gibi kitle iletişim araçlarıyla size yapılacak uyarıları dinleyin.\n\n" +
                          "Cadde ve sokakları acil yardım araçları için boş bırakın.\nHer büyük depremden sonra mutlaka artçı depremler olur. Artçı depremler zaman içerisinde seyrekleşir ve büyüklükleri azalır. Artçı depremler hasarlı binalarda zarara yol açabilir. Bu nedenle sarsıntılar tamamen bitene kadar hasarlı binalara girilmemelidir. Artçı depremler sırasında da ana depremde yapılması gerekenler yapılmalıdır.\n\n",
                      textAlign: TextAlign.justify,
                      style: TextStyle(fontSize: 20),
                    ),
                    Text(
                      "AÇIK ALANDAYSANIZ\n",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 23),
                    ),
                    Text(
                      "Çevrenizdeki hasara dikkat ederek bunları not edin.\n\n" +
                          "Hasarlı binalardan ve enerji nakil hatlarından uzak durun.\n\n" +
                          "Önce yakın çevrenizde acil yardıma gerek duyanlara yardım edin.\n\n" +
                          "Sonra mahalle toplanma noktanıza gidin.\n\n" +
                          "Yardım çalışmalarına katılın. Özel ilgiye ihtiyacı olan afetzedelere -yaşlılar, bebekler, hamileler, engelliler- yardımcı olun.\n\n",
                      textAlign: TextAlign.justify,
                      style: TextStyle(fontSize: 20),
                    ),
                    Text(
                      "YIKINTI ALTINDA MAHSUR KALDIYSANIZ\n",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 23),
                    ),
                    Text(
                      "Paniklemeden durumunuzu kontrol edin.\n\n" +
                          "Hareket kabiliyetiniz kısıtlanmışsa çıkış için hayatınızı riske atacak hareketlere kalkışmayın. Biliniz ki kurtarma ekipleri en kısa zamanda size ulaşmak için çaba gösterecektir.\n\n" +
                          "Enerjinizi en tasarruflu şekilde kullanmak için hareketlerinizi kontrol altında tutun.\n\n" +
                          "El ve ayaklarınızı kullanabiliyorsanız su, kalorifer, gaz tesisatlarına, zemine vurmak suretiyle varlığınızı duyurmaya çalışın.\nSesinizi kullanabiliyorsanız kurtarma ekiplerinin seslerini duymaya ve onlara seslenmeye çalışınız. Ancak enerjinizi kontrollü kullanın.\n\n",
                      textAlign: TextAlign.justify,
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
            ),
            //third tab
            SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 10.0,
                  ),
                  CheckboxListTile(
                    title: const Text(
                      'Bir kişiye üç gün yetecek kadar su',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    value: bagItemsChecked[0],
                    onChanged: (bool value) {
                      setState(() {
                        bagItemsChecked[0] = !bagItemsChecked[0];
                      });
                      setPref();
                    },
                  ),
                  Divider(),
                  CheckboxListTile(
                    title: const Text(
                      'Bir kişiye üç gün yetecek miktarda bozulmaya dayanıklı gıda',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    value: bagItemsChecked[1],
                    onChanged: (bool value) {
                      setState(() {
                        bagItemsChecked[1] = !bagItemsChecked[1];
                      });
                      setPref();
                    },
                  ),
                  Divider(),
                  CheckboxListTile(
                    title: const Text(
                      'Pilli radyo',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    value: bagItemsChecked[2],
                    onChanged: (bool value) {
                      setState(() {
                        bagItemsChecked[2] = !bagItemsChecked[2];
                      });
                      setPref();
                    },
                  ),
                  Divider(),
                  CheckboxListTile(
                    title: const Text(
                      'El feneri',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    value: bagItemsChecked[3],
                    onChanged: (bool value) {
                      setState(() {
                        bagItemsChecked[3] = !bagItemsChecked[3];
                      });
                      setPref();
                    },
                  ),
                  Divider(),
                  CheckboxListTile(
                    title: const Text(
                      'Ekstra pil',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    value: bagItemsChecked[4],
                    onChanged: (bool value) {
                      setState(() {
                        bagItemsChecked[4] = !bagItemsChecked[4];
                      });
                      setPref();
                    },
                  ),
                  Divider(),
                  CheckboxListTile(
                    title: const Text(
                      'İlk yardım çantası',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    value: bagItemsChecked[5],
                    onChanged: (bool value) {
                      setState(() {
                        bagItemsChecked[5] = !bagItemsChecked[5];
                      });
                      setPref();
                    },
                  ),
                  Divider(),
                  CheckboxListTile(
                    title: const Text(
                      'Yardım çağırmak için düdük',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    value: bagItemsChecked[6],
                    onChanged: (bool value) {
                      setState(() {
                        bagItemsChecked[6] = !bagItemsChecked[6];
                      });
                      setPref();
                    },
                  ),
                  Divider(),
                  CheckboxListTile(
                    title: const Text(
                      'Mevsime uygun temiz giysi',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    value: bagItemsChecked[7],
                    onChanged: (bool value) {
                      setState(() {
                        bagItemsChecked[7] = !bagItemsChecked[7];
                      });
                      setPref();
                    },
                  ),
                  Divider(),
                  CheckboxListTile(
                    title: const Text(
                      'Konserve açacağı da içeren çok amaçlı çakı',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    value: bagItemsChecked[8],
                    onChanged: (bool value) {
                      setState(() {
                        bagItemsChecked[8] = !bagItemsChecked[8];
                      });
                      setPref();
                    },
                  ),
                  Divider(),
                  CheckboxListTile(
                    title: const Text(
                      'Çöp poşeti',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    value: bagItemsChecked[9],
                    onChanged: (bool value) {
                      setState(() {
                        bagItemsChecked[9] = !bagItemsChecked[9];
                      });
                      setPref();
                    },
                  ),
                  Divider(),
                  CheckboxListTile(
                    title: const Text(
                      'Önemli evraklar',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    value: bagItemsChecked[10],
                    onChanged: (bool value) {
                      setState(() {
                        bagItemsChecked[10] = !bagItemsChecked[10];
                      });
                      setPref();
                    },
                  ),
                  Divider(),
                  CheckboxListTile(
                    title: const Text(
                      'Kişisel hijyen malzemeleri',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    value: bagItemsChecked[11],
                    onChanged: (bool value) {
                      setState(() {
                        bagItemsChecked[11] = !bagItemsChecked[11];
                      });
                      setPref();
                    },
                  ),
                  Divider(),
                  CheckboxListTile(
                    title: const Text(
                      'Düzenli kullanılan ilaçlar',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    value: bagItemsChecked[12],
                    onChanged: (bool value) {
                      setState(() {
                        bagItemsChecked[12] = !bagItemsChecked[12];
                      });
                      setPref();
                    },
                  ),
                  Divider(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
