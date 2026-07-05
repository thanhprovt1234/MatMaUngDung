<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>

<body>
	<%@include file="/common/web/slider.jsp"%>
	<section>
		<div class="container">
			<div class="row">
				<div class="col-sm-3">
					<div class="left-sidebar">
						<h2>Category</h2>
						<div class="panel-group category-products" id="accordion">
							<c:forEach var="category" items="${categories}">
								<div class="panel panel-default">
									<div class="panel-heading">
										<h4 class="panel-title">
											<a data-toggle="collapse" data-parent="#accordion"
												href="#category-${category._id}"> <span
												class="badge pull-right"><i class="fa fa-plus"></i></span>
												${category.name}
											</a>
										</h4>
									</div>
									<div id="category-${category._id}"
										class="panel-collapse collapse">
										<div class="panel-body">
											<ul>
												<c:forEach var="product" items="${category.products}">
													<a
														href="${pageContext.request.contextPath}/home/productDetail?id=${product._id}"><li>${product.name}</li></a>
												</c:forEach>
											</ul>
										</div>
									</div>
								</div>
							</c:forEach>
						</div>

						<!--/category-products-->



						<!-- <div class="price-range">
							price-range
							<h2>Price Range</h2>
							<div class="well text-center">
								<input type="text" class="span2" value="" data-slider-min="0"
									data-slider-max="600" data-slider-step="5"
									data-slider-value="[250,450]" id="sl2"><br /> <b
									class="pull-left">$ 0</b> <b class="pull-right">$ 600</b>
							</div>
						</div> -->
						<!-- Bộ lọc giá tiền -->
						<!-- Bộ lọc giá tiền -->
						<div class="price-range">
							<h2>Price Range</h2>
							<form action="${pageContext.request.contextPath}/home"
								method="get" class="well text-center">
								<input type="number" name="minPrice" class="form-control mb-2"
									placeholder="Min Price ($)" /> <input type="number"
									name="maxPrice" class="form-control mb-2"
									placeholder="Max Price ($)" />
								<button type="submit" class="btn btn-primary">Filter</button>
							</form>
							<!-- Hiển thị thông báo lỗi nếu có -->
							<c:if test="${not empty errorMessage}">
								<div class="alert alert-danger" style="margin-top: 10px;">
									${errorMessage}</div>
							</c:if>
						</div>


						<!-- Nút sắp xếp giá -->
						<div class="sorting mt-3">
							<h2>Sort By</h2>
							<button class="btn btn-secondary"
								onclick="location.href='${pageContext.request.contextPath}/home?sort=sales'">Bán
								chạy</button>
							<button class="btn btn-secondary"
								onclick="location.href='${pageContext.request.contextPath}/home?sort=priceAsc'">Giá:
								Thấp đến cao</button>
							<button class="btn btn-secondary"
								onclick="location.href='${pageContext.request.contextPath}/home?sort=priceDesc'">Giá:
								Cao đến thấp</button>
						</div>

						<!--/price-range-->

						<div class="shipping text-center">
							<!--shipping-->
							<img src="${URL}Eshopper/images/home/shipping.jpg" alt="" />
						</div>
						<!--/shipping-->

					</div>
				</div>

				<div class="col-sm-9 padding-right">
					<div class="features_items" id="featured-products">
						<!--features_items-->
						<h2 class="title text-center">Danh sách sản phẩm</h2>
						<c:forEach var="product" items="${products}">
							<div class="col-sm-4">
								<div class="product-image-wrapper">
									<div class="single-products">
										<div class="productinfo text-center">
											<a
												href="${pageContext.request.contextPath}/home/productDetail?id=${product._id}">
												<img src="${pageContext.request.contextPath}/images/product/${product.firstImage}" alt="" 
												style="width: 268px; height: 249px; object-fit: cover;"/>
											</a>
											<h2>${product.price}$</h2>
											<p>${product.name}</p>
											<form action="${pageContext.request.contextPath}/cart/add" method="post" style="display:inline;">
  													<input type="hidden" name="csrfToken" value="${csrfToken}" />
  													<input type="hidden" name="productId" value="${product._id}" />
  													<input type="hidden" name="quantity" value="1" />
  													<button type="submit" class="btn btn-default add-to-cart">
   											 <i class="fa fa-shopping-cart"></i>Add to cart
  												</button>
											</form>
										</div>
									</div>
									<div class="choose">
										<ul class="nav nav-pills nav-justified">
											<li><a href="#"><i class="fa fa-plus-square"></i>Add
													to wishlist</a></li>
											<li><span class="sold-info"><i
													class="fa fa-plus-square"></i> Đã bán: ${product.sold}</span></li>
										</ul>
									</div>
								</div>
							</div>
						</c:forEach>
					</div>

					<!--features_items-->
					<!-- Tab Category -->
					<div class="category-tab">
						<!--category-tab-->
						<div class="col-sm-12">
							<ul class="nav nav-tabs">
								<c:forEach var="category" items="${randomcategories}"
									varStatus="status">
									<li class="${status.first ? 'active' : ''}"><a
										href="#category-${category._id}" data-toggle="tab"
										onclick="loadProducts(${category._id})">${category.name}</a></li>
								</c:forEach>
							</ul>
						</div>
						<div class="tab-content">
							<div class="tab-pane fade active in" id="products-container">
								<c:forEach var="product" items="${productsCate}">
									<div class="col-sm-4">
										<div class="product-image-wrapper">
											<div class="single-products">
												<div class="productinfo text-center">
													<img
														src="${pageContext.request.contextPath}/images/shop/1001.jpg"
														alt="" style="width: 260px; height: 260px" />
													<h2>${product.price}$</h2>
													<p>${product.name}</p>
													<a
														href="${pageContext.request.contextPath}/home/productDetail?id=${product._id}"
														class="btn btn-default add-to-cart"><i
														class="fa fa-shopping-cart"></i>Add to cart</a>
												</div>
											</div>
											<div class="choose">
												<ul class="nav nav-pills nav-justified">
													<li><a
														href="${pageContext.request.contextPath}/home/productDetail?id=${product._id}">
															<i class="fa fa-plus-square"></i>Views Details
													</a></li>
													<li><a href="${pageContext.request.contextPath}/home/cart/add/${product._id}"> <i
															class="fa fa-plus-square"></i>Add to cart
													</a></li>
												</ul>
											</div>
										</div>
									</div>
								</c:forEach>
							</div>
						</div>
					</div>
					<!--/category-tab-->


					<div class="recommended_items">
						<!--recommended_items-->
						<h2 class="title text-center">recommended items</h2>

						<div id="recommended-item-carousel" class="carousel slide"
							data-ride="carousel">
							<div class="carousel-inner">
								<div class="item active">
									<div class="col-sm-4">
										<div class="product-image-wrapper">
											<div class="single-products">
												<div class="productinfo text-center">
													<img src="${URL}Eshopper/images/home/recommend1.jpg" alt="" />
													<h2>$56</h2>
													<p>Easy Polo Black Edition</p>
													<a href="#featured-products" class="btn btn-default add-to-cart"><i
														class="fa fa-shopping-cart"></i>View products</a>
												</div>

											</div>
										</div>
									</div>
									<div class="col-sm-4">
										<div class="product-image-wrapper">
											<div class="single-products">
												<div class="productinfo text-center">
													<img src="${URL}Eshopper/images/home/recommend2.jpg" alt="" />
													<h2>$56</h2>
													<p>Easy Polo Black Edition</p>
													<a href="#featured-products" class="btn btn-default add-to-cart"><i
														class="fa fa-shopping-cart"></i>View products</a>
												</div>

											</div>
										</div>
									</div>
									<div class="col-sm-4">
										<div class="product-image-wrapper">
											<div class="single-products">
												<div class="productinfo text-center">
													<img src="${URL}Eshopper/images/home/recommend3.jpg" alt="" />
													<h2>$56</h2>
													<p>Easy Polo Black Edition</p>
													<a href="#featured-products" class="btn btn-default add-to-cart"><i
														class="fa fa-shopping-cart"></i>View products</a>
												</div>

											</div>
										</div>
									</div>
								</div>
								<div class="item">
									<div class="col-sm-4">
										<div class="product-image-wrapper">
											<div class="single-products">
												<div class="productinfo text-center">
													<img src="${URL}Eshopper/images/home/recommend1.jpg" alt="" />
													<h2>$56</h2>
													<p>Easy Polo Black Edition</p>
													<a href="#featured-products" class="btn btn-default add-to-cart"><i
														class="fa fa-shopping-cart"></i>View products</a>
												</div>

											</div>
										</div>
									</div>
									<div class="col-sm-4">
										<div class="product-image-wrapper">
											<div class="single-products">
												<div class="productinfo text-center">
													<img src="${URL}Eshopper/images/home/recommend2.jpg" alt="" />
													<h2>$56</h2>
													<p>Easy Polo Black Edition</p>
													<a href="#featured-products" class="btn btn-default add-to-cart"><i
														class="fa fa-shopping-cart"></i>View products</a>
												</div>

											</div>
										</div>
									</div>
									<div class="col-sm-4">
										<div class="product-image-wrapper">
											<div class="single-products">
												<div class="productinfo text-center">
													<img src="${URL}Eshopper/images/home/recommend3.jpg" alt="" />
													<h2>$56</h2>
													<p>Easy Polo Black Edition</p>
													<a href="#featured-products" class="btn btn-default add-to-cart"><i
														class="fa fa-shopping-cart"></i>View products</a>
												</div>

											</div>
										</div>
									</div>
								</div>
							</div>
							<a class="left recommended-item-control"
								href="#recommended-item-carousel" data-slide="prev"> <i
								class="fa fa-angle-left"></i>
							</a> <a class="right recommended-item-control"
								href="#recommended-item-carousel" data-slide="next"> <i
								class="fa fa-angle-right"></i>
							</a>
						</div>
					</div>
					<!--/recommended_items-->

				</div>
			</div>
		</div>
	</section>




	<script src="${URL}Eshopper/js/jquery.js"></script>
	<script src="${URL}Eshopper/js/bootstrap.min.js"></script>
	<script src="${URL}Eshopper/js/jquery.scrollUp.min.js"></script>
	<script src="${URL}Eshopper/js/price-range.js"></script>
	<script src="${URL}Eshopper/js/jquery.prettyPhoto.js"></script>
	<script src="${URL}Eshopper/js/main.js"></script>
	<script type="text/javascript"></script>
	<script>
function loadProducts(categoryId) {
	$.ajax({
		url: '${pageContext.request.contextPath}/home/productsByCategory', // URL đến API backend
		type: 'GET',
		data: { categoryId: categoryId },
		success: function(response) {
			// Cập nhật danh sách sản phẩm
			$('#products-container').html(response);
		},
		error: function(err) {
			console.error('Error loading products:', err);
		}
	});
}


</script>
</body>
</html>


