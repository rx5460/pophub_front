import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pophub/model/goods_model.dart';
import 'package:pophub/screen/goods/goods_order.dart';
import 'package:pophub/utils/api.dart';
import 'package:pophub/utils/log.dart';

class GoodsDetail extends StatefulWidget {
  final String goodsId;
  const GoodsDetail({Key? key, required this.goodsId}) : super(key: key);

  @override
  State<GoodsDetail> createState() => _GoodsDetailState();
}

class _GoodsDetailState extends State<GoodsDetail> {
  int _current = 0;
  final CarouselController _controller = CarouselController();
  bool isLoading = false;
  bool isBuying = false;
  GoodsModel? goods;
  int count = 1;

  @override
  void initState() {
    super.initState();
    getGoodsData();
  }

  Future<void> getGoodsData() async {
    try {
      GoodsModel? data = await Api.getPopupGoodsDetail(widget.goodsId);
      setState(() {
        goods = data;
        isLoading = true;
      });
    } catch (error) {
      // 오류 처리
      Logger.debug('Error fetching goods data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;

    return Scaffold(
      body: !isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height:
                          isBuying ? screenHeight * 0.8 : screenHeight * 0.9,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Container(
                              width: screenWidth,
                              height: AppBar().preferredSize.height,
                              decoration:
                                  const BoxDecoration(color: Colors.white),
                            ),
                            Stack(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    sliderWidget(),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Transform.translate(
                                          offset: Offset(0, -screenWidth * 0.1),
                                          child: Container(
                                            width: screenWidth * 0.17,
                                            height: screenWidth * 0.06,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                Radius.circular(8),
                                              ),
                                              color:
                                                  Colors.white.withOpacity(0.2),
                                            ),
                                            child: Center(
                                              child: Text(
                                                '${(_current + 1).toString()}/${goods?.image?.length ?? 0}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: screenWidth * 0.05,
                                          right: screenWidth * 0.05),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 12.0),
                                            child: Text(
                                              goods?.productName ?? '',
                                              style: const TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            '${goods!.price.toString()}원',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.info_outline,
                                                size: 20,
                                              ),
                                              SizedBox(
                                                width: 8,
                                              ),
                                              Text(
                                                '1인당 3개까지 구매 가능합니다.',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            padding: const EdgeInsets.only(
                                                top: 12, bottom: 12),
                                            width: screenWidth * 0.9,
                                            child: Text(
                                              goods!.description,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 20, bottom: 10),
                                                child: SizedBox(
                                                  width: screenWidth * 0.9,
                                                  child: const Text(
                                                    '이 스토어의 다른 제품들',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    width: screenWidth * 0.9,
                                                    height: screenWidth * 0.5,
                                                    child: Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 0,
                                                          right: screenWidth *
                                                              0.05),
                                                      child: GestureDetector(
                                                        onTap: () {},
                                                        child: SizedBox(
                                                          width:
                                                              screenWidth * 0.5,
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                child:
                                                                    Image.asset(
                                                                  'assets/images/Untitled.png',
                                                                  width:
                                                                      screenWidth *
                                                                          0.35,
                                                                ),
                                                              ),
                                                              const Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        top:
                                                                            8.0),
                                                                child: Text(
                                                                  '굿즈 이름',
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w900,
                                                                  ),
                                                                ),
                                                              ),
                                                              const Text(
                                                                '수량',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 11,
                                                                  color: Colors
                                                                      .grey,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w900,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 30,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Positioned(
                                  top: -AppBar().preferredSize.height + 5,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    color: Colors.transparent,
                                    child: AppBar(
                                      systemOverlayStyle:
                                          SystemUiOverlayStyle.dark,
                                      backgroundColor: Colors.transparent,
                                      elevation: 0,
                                      leading: IconButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        icon: const Icon(
                                          Icons.arrow_back_ios,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      // duration: const Duration(milliseconds: 300),
                      width: screenWidth,
                      height:
                          isBuying ? screenHeight * 0.2 : screenHeight * 0.1,
                      decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              width: 2,
                              color: Color(0xFFADD8E6),
                            ),
                          ),
                          color: Colors.white),
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: screenWidth * 0.05,
                            right: screenWidth * 0.05,
                            bottom: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            isBuying
                                ? const SizedBox()
                                : Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {},
                                        child: const Icon(
                                          Icons.favorite_border,
                                          size: 30,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      const Text(
                                        '26',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                isBuying
                                    ? SizedBox(
                                        width: screenWidth * 0.8,
                                        height: screenHeight * 0.1,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    goods!.productName,
                                                    style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w900),
                                                  ),
                                                  Text(
                                                    '${goods!.price.toString()}원',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ]),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      if (count != 0) {
                                                        count -= 1;
                                                      }
                                                    });
                                                  },
                                                  child: const Icon(
                                                    Icons.remove,
                                                    size: 20,
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 8, right: 8),
                                                  child: Text(
                                                    count.toString(),
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      count += 1;
                                                    });
                                                  },
                                                  child: const Icon(
                                                    Icons.add,
                                                    size: 20,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                    : const SizedBox(),
                                Container(
                                  // duration: const Duration(milliseconds: 300),
                                  width: isBuying
                                      ? screenWidth * 0.9
                                      : screenWidth * 0.3,
                                  height: isBuying
                                      ? screenHeight * 0.06
                                      : screenHeight * 0.05,
                                  decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10)),
                                      border: Border.all(
                                        width: 2,
                                        color: const Color(0xFFADD8E6),
                                      ),
                                      color: const Color(0xFFADD8E6)),
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        if (!isBuying) {
                                          isBuying = !isBuying;
                                        } else {
                                          // 결제페이지
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    GoodsOrder(
                                                      count: count,
                                                    )),
                                          );
                                        }
                                      });
                                    },
                                    child: const Center(
                                      child: Text(
                                        '구매하기',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (isBuying)
                  Positioned(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isBuying = false;
                            });
                          },
                          child: Container(
                            // duration: const Duration(milliseconds: 400),
                            height: screenHeight * 0.8,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }

  Widget sliderWidget() {
    return CarouselSlider(
      carouselController: _controller,
      items: goods?.image?.map(
            (img) {
              return Builder(
                builder: (context) {
                  return SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Image.network(
                      img,
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.fill,
                    ),
                  );
                },
              );
            },
          ).toList() ??
          [],
      options: CarouselOptions(
        height: 300,
        viewportFraction: 1.0,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 4),
        onPageChanged: (index, reason) {
          setState(() {
            _current = index;
          });
        },
      ),
    );
  }
}
