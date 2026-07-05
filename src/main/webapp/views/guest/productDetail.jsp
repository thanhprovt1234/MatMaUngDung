<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fn" uri="jakarta.tags.functions"%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>Product Details | E-Shopper</title>

</head>
<!--/head-->

<body>
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
						<div class="brands_products">
							<!--brands_products-->
							<h2>Brands</h2>
							<div class="brands-name">
								<ul class="nav nav-pills nav-stacked">
									<li><a href=""> <span class="pull-right">(50)</span>Acne
									</a></li>
									<li><a href=""> <span class="pull-right">(56)</span>GrÃ¼ne
											Erde
									</a></li>
									<li><a href=""> <span class="pull-right">(27)</span>Albiro
									</a></li>
									<li><a href=""> <span class="pull-right">(32)</span>Ronhill
									</a></li>
									<li><a href=""> <span class="pull-right">(5)</span>Oddmolly
									</a></li>
									<li><a href=""> <span class="pull-right">(9)</span>Boudestijn
									</a></li>
									<li><a href=""> <span class="pull-right">(4)</span>RÃ¶sch
											creative culture
									</a></li>
								</ul>
							</div>
						</div>
						<!--/brands_products-->

						<!--/price-range-->
						<div class="shipping text-center">
							<!--shipping-->
							<img src="images/home/shipping.jpg" alt="" />
						</div>
						<!--/shipping-->
					</div>
				</div>
				<div class="col-sm-9 padding-right">
					<div class="product-details">
						<!--product-details-->
						<div class="col-sm-5">
							<div class="view-product">
								<img
									src="${pageContext.request.contextPath}/images/product/${product.firstImage}"
									alt="" />
								<h3>ZOOM</h3>
							</div>
							<div id="similar-product" class="carousel slide"
								data-ride="carousel">
								<!-- Wrapper for slides -->
								<div class="carousel-inner">
									<c:forEach var="image" items="${product.listImages}"
										varStatus="status">
										<c:if test="${status.index % 3 == 0}">
											<div class="item ${status.index == 0 ? 'active' : ''}">
										</c:if>
										<a href="#"> <img src="${image}" alt="${product.name}"
											style="width: 84px; height: 84px;">
										</a>
										<c:if test="${status.index % 3 == 2 || status.last}">
								</div>
								</c:if>
								</c:forEach>
							</div>

							<!-- Controls -->
							<a class="left item-control" href="#similar-product"
								data-slide="prev"> <i class="fa fa-angle-left"></i>
							</a> <a class="right item-control" href="#similar-product"
								data-slide="next"> <i class="fa fa-angle-right"></i>
							</a>
						</div>






					</div>
					<div class="col-sm-7">
						<div class="product-information">
							<!--/product-information-->
							<img src="" class="newarrival" alt="" />
							<h2>${product.name}</h2>
							<p>Mô tả: ${product.description}</p>
							<img
								src="${pageContext.request.contextPath}/images/product-details/rating.png"
								alt="" /> <span> <span>US $${product.price}</span>
								<form action="${pageContext.request.contextPath}/cart/add"
									method="POST">
									<input type="hidden" name="csrfToken" value="${csrfToken}">
									<input type="hidden" name="productId" value="${product._id}">
									<div class="form-group">
										<label for="quantity-${product._id}">Quantity:</label> <input
											type="number" id="quantity-${product._id}" name="quantity"
											value="1" min="1" class="form-control" required>
									</div>
									<button type="submit" class="btn btn-fefault cart">
										<i class="fa fa-shopping-cart"></i> Add to cart
									</button>
								</form>

							</span>
							<p>
								<strong>Còn lại:</strong> ${product.quantity} sản phẩm
							</p>
							<p>
								<strong>Danh mục:</strong> ${product.category.name}
							</p>
							<p>
								<strong>Đã bán:</strong> ${product.sold}
							</p>
							<form action="${pageContext.request.contextPath}/user/follow"
								method="POST">
								<input type="hidden" name="csrfToken" value="${csrfToken}">
								<input type="hidden" name="userId"
									value="${sessionScope.account._id}"> <input
									type="hidden" name="productId" value="${product._id}">
								<button type="submit" class="btn btn-fefault cart">
									<i class="fa fa-heart"></i> Follow Product
								</button>
							</form>
							<a href=""><img
								src="${pageContext.request.contextPath}/images/product-details/share.png"
								class="share img-responsive" alt="" /></a>
						</div>
						<!--/product-information-->
					</div>
				</div>
				<!--/product-details-->
				<div class="category-tab shop-details-tab">
					<!--category-tab-->
					<div class="col-sm-12">
						<ul class="nav nav-tabs">
							<li><a href="#details" data-toggle="tab">Details</a></li>
							<li><a href="#companyprofile" data-toggle="tab">Company
									Profile</a></li>
							<li><a href="#tag" data-toggle="tab">Tag</a></li>
							<li class="active"><a href="#reviews" data-toggle="tab">Reviews
									(5)</a></li>
						</ul>
					</div>
					<div class="tab-content">
						<div class="tab-pane fade" id="details">
							<div class="col-sm-3">
								<div class="product-image-wrapper">
									<div class="single-products">
										<div class="productinfo text-center">
											<img src="images/home/gallery1.jpg" alt="" />
											<h2>$56</h2>
											<p>Easy Polo Black Edition</p>
											<button type="button" class="btn btn-default add-to-cart">
												<i class="fa fa-shopping-cart"></i>Add to cart
											</button>
										</div>
									</div>
								</div>
							</div>
							<div class="col-sm-3">
								<div class="product-image-wrapper">
									<div class="single-products">
										<div class="productinfo text-center">
											<img src="images/home/gallery2.jpg" alt="" />
											<h2>$56</h2>
											<p>Easy Polo Black Edition</p>
											<button type="button" class="btn btn-default add-to-cart">
												<i class="fa fa-shopping-cart"></i>Add to cart
											</button>
										</div>
									</div>
								</div>
							</div>
							<div class="col-sm-3">
								<div class="product-image-wrapper">
									<div class="single-products">
										<div class="productinfo text-center">
											<img src="images/home/gallery3.jpg" alt="" />
											<h2>$56</h2>
											<p>Easy Polo Black Edition</p>
											<button type="button" class="btn btn-default add-to-cart">
												<i class="fa fa-shopping-cart"></i>Add to cart
											</button>
										</div>
									</div>
								</div>
							</div>
							<div class="col-sm-3">
								<div class="product-image-wrapper">
									<div class="single-products">
										<div class="productinfo text-center">
											<img src="images/home/gallery4.jpg" alt="" />
											<h2>$56</h2>
											<p>Easy Polo Black Edition</p>
											<button type="button" class="btn btn-default add-to-cart">
												<i class="fa fa-shopping-cart"></i>Add to cart
											</button>
										</div>
									</div>
								</div>
							</div>
						</div>
						<div class="tab-pane fade" id="companyprofile">
							<div class="col-sm-3">
								<div class="product-image-wrapper">
									<div class="single-products">
										<div class="productinfo text-center">
											<img src="images/home/gallery1.jpg" alt="" />
											<h2>$56</h2>
											<p>Easy Polo Black Edition</p>
											<button type="button" class="btn btn-default add-to-cart">
												<i class="fa fa-shopping-cart"></i>Add to cart
											</button>
										</div>
									</div>
								</div>
							</div>
							<div class="col-sm-3">
								<div class="product-image-wrapper">
									<div class="single-products">
										<div class="productinfo text-center">
											<img src="images/home/gallery3.jpg" alt="" />
											<h2>$56</h2>
											<p>Easy Polo Black Edition</p>
											<button type="button" class="btn btn-default add-to-cart">
												<i class="fa fa-shopping-cart"></i>Add to cart
											</button>
										</div>
									</div>
								</div>
							</div>
							<div class="col-sm-3">
								<div class="product-image-wrapper">
									<div class="single-products">
										<div class="productinfo text-center">
											<img src="images/home/gallery2.jpg" alt="" />
											<h2>$56</h2>
											<p>Easy Polo Black Edition</p>
											<button type="button" class="btn btn-default add-to-cart">
												<i class="fa fa-shopping-cart"></i>Add to cart
											</button>
										</div>
									</div>
								</div>
							</div>
							<div class="col-sm-3">
								<div class="product-image-wrapper">
									<div class="single-products">
										<div class="productinfo text-center">
											<img src="images/home/gallery4.jpg" alt="" />
											<h2>$56</h2>
											<p>Easy Polo Black Edition</p>
											<button type="button" class="btn btn-default add-to-cart">
												<i class="fa fa-shopping-cart"></i>Add to cart
											</button>
										</div>
									</div>
								</div>
							</div>
						</div>
						<div class="tab-pane fade" id="tag">
							<div class="col-sm-3">
								<div class="product-image-wrapper">
									<div class="single-products">
										<div class="productinfo text-center">
											<img src="images/home/gallery1.jpg" alt="" />
											<h2>$56</h2>
											<p>Easy Polo Black Edition</p>
											<button type="button" class="btn btn-default add-to-cart">
												<i class="fa fa-shopping-cart"></i>Add to cart
											</button>
										</div>
									</div>
								</div>
							</div>
							<div class="col-sm-3">
								<div class="product-image-wrapper">
									<div class="single-products">
										<div class="productinfo text-center">
											<img src="images/home/gallery2.jpg" alt="" />
											<h2>$56</h2>
											<p>Easy Polo Black Edition</p>
											<button type="button" class="btn btn-default add-to-cart">
												<i class="fa fa-shopping-cart"></i>Add to cart
											</button>
										</div>
									</div>
								</div>
							</div>
							<div class="col-sm-3">
								<div class="product-image-wrapper">
									<div class="single-products">
										<div class="productinfo text-center">
											<img src="images/home/gallery3.jpg" alt="" />
											<h2>$56</h2>
											<p>Easy Polo Black Edition</p>
											<button type="button" class="btn btn-default add-to-cart">
												<i class="fa fa-shopping-cart"></i>Add to cart
											</button>
										</div>
									</div>
								</div>
							</div>
							<div class="col-sm-3">
								<div class="product-image-wrapper">
									<div class="single-products">
										<div class="productinfo text-center">
											<img src="images/home/gallery4.jpg" alt="" />
											<h2>$56</h2>
											<p>Easy Polo Black Edition</p>
											<button type="button" class="btn btn-default add-to-cart">
												<i class="fa fa-shopping-cart"></i>Add to cart
											</button>
										</div>
									</div>
								</div>
							</div>
						</div>
						<div class="tab-pane fade active in" id="reviews">
							<div class="customer-reviews-container col-sm-12">
								<h3 class="reviews-title">Customer Reviews</h3>
								<ul class="reviews-list">
									<c:forEach items="${reviews}" var="review">
										<li class="review-item">
											<p class="review-user">
												<strong>${review.user.firstname}
													${review.user.lastname}</strong>
											</p>
											<p class="review-date">${review.createdAt}</p>
											<p class="review-content">${review.content}</p>
											<p class="review-rating">Rating: ${review.stars} Stars</p>
										</li>
									</c:forEach>
								</ul>
							</div>
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
												<img src="images/home/recommend1.jpg" alt="" />
												<h2>$56</h2>
												<p>Easy Polo Black Edition</p>
												<button type="button" class="btn btn-default add-to-cart">
													<i class="fa fa-shopping-cart"></i>Add to cart
												</button>
											</div>
										</div>
									</div>
								</div>
								<div class="col-sm-4">
									<div class="product-image-wrapper">
										<div class="single-products">
											<div class="productinfo text-center">
												<img src="images/home/recommend2.jpg" alt="" />
												<h2>$56</h2>
												<p>Easy Polo Black Edition</p>
												<button type="button" class="btn btn-default add-to-cart">
													<i class="fa fa-shopping-cart"></i>Add to cart
												</button>
											</div>
										</div>
									</div>
								</div>
								<div class="col-sm-4">
									<div class="product-image-wrapper">
										<div class="single-products">
											<div class="productinfo text-center">
												<img src="images/home/recommend3.jpg" alt="" />
												<h2>$56</h2>
												<p>Easy Polo Black Edition</p>
												<button type="button" class="btn btn-default add-to-cart">
													<i class="fa fa-shopping-cart"></i>Add to cart
												</button>
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
												<img src="images/home/recommend1.jpg" alt="" />
												<h2>$56</h2>
												<p>Easy Polo Black Edition</p>
												<button type="button" class="btn btn-default add-to-cart">
													<i class="fa fa-shopping-cart"></i>Add to cart
												</button>
											</div>
										</div>
									</div>
								</div>
								<div class="col-sm-4">
									<div class="product-image-wrapper">
										<div class="single-products">
											<div class="productinfo text-center">
												<img src="images/home/recommend2.jpg" alt="" />
												<h2>$56</h2>
												<p>Easy Polo Black Edition</p>
												<button type="button" class="btn btn-default add-to-cart">
													<i class="fa fa-shopping-cart"></i>Add to cart
												</button>
											</div>
										</div>
									</div>
								</div>
								<div class="col-sm-4">
									<div class="product-image-wrapper">
										<div class="single-products">
											<div class="productinfo text-center">
												<img src="images/home/recommend3.jpg" alt="" />
												<h2>$56</h2>
												<p>Easy Polo Black Edition</p>
												<button type="button" class="btn btn-default add-to-cart">
													<i class="fa fa-shopping-cart"></i>Add to cart
												</button>
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
</body>
</html>
