package  
{
	import com.greensock.TweenLite;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.filters.DropShadowFilter;
	import flash.utils.*;

	/**
	 * A fancy sliced pie navigation.
	 * 
	 * @author Sebastian Herrlinger
	 */
	public class PieSlice extends Sprite
	{
		//All times are Milliseconds
		private static const HIDE_CHILDREN_TIMEOUT:Number = 2000;
		private static const SHOW_OPEN_CHILDREN_ANIMATION_TIME:Number = 500;
		private static const HIDE_OPEN_CHILDREN_ANIMATION_TIME:Number = 500;
		private static const SHOW_CLOSED_CHILDREN_ANIMATION_TIME:Number = 500;
		private static const HIDE_CLOSED_CHILDREN_ANIMATION_TIME:Number = 500;
		private static const SHOW_CLOSED_CHILDREN_DELAY_INTERVAL:Number = 100;
		private static const SHOW_OPEN_CHILDREN_DELAY_INTERVAL:Number = 100;
		private static const HIDE_CLOSED_CHILDREN_DELAY_INTERVAL:Number = 100;
		private static const HIDE_OPEN_CHILDREN_REDUCTION_INTERVAL:Number = 100;
		private static const CLOSED_CHILDREN_SIZE:Number = 3;
			
		private var _slices:Array = new Array();
		private var _parentSlice:PieSlice = null;
		private var _angle:Number = 0;
		private var _innerRadius:Number = 0;
		private var _outerRadius:Number = 50;
		private var _degreeSize:Number = 360;
		private var _size:Number = 30;
		private var _maxChildrenAutoDegreeSize:Number = 40;
		private var _maxChildrenAutoClosedDegreeSize:Number = 20;
		private var _childSliceSpacing:Number = 1;
		private var _opened:Boolean = false;
		
		private var _sliceContainer:Sprite = new Sprite();
		private var _sliceShape:Sprite = new Sprite();
		
		private var _hideChildrenTimeout:uint = 0x0;
		
		//Pie Slice drawing
		private static const PIBY180:Number = Math.PI / 180;
		private var drawPieSliceAngle1:Number = 0;
		private var drawPieSliceAngle2:Number = 0;
		private var drawPieSlicePoint1:Point = new Point();
		
		public var color:uint = 0x76C7C6;
		
		public function PieSlice()
		{
			addChild(_sliceContainer);
			addChild(_sliceShape);
			_sliceShape.addEventListener(MouseEvent.MOUSE_OVER, clearTimeoutListener);
			
			drawThis();
		}
		
		public function moveChildToTop(child:PieSlice):void
		{
			_sliceContainer.setChildIndex(child, _slices.length-1);
		}
		
		public function closeNeighbours():void
		{
			if (_parentSlice != null)
			{
				for each(var childSlice:PieSlice in _parentSlice.slices)
				{
					if (childSlice != this && childSlice.opened)
						childSlice.showClosedChildren(300);
				}
			}
		}
		
		public function activate():void
		{
			_sliceShape.addEventListener(MouseEvent.MOUSE_OVER, showOpenChildrenListener);
			//_sliceShape.addEventListener(MouseEvent.MOUSE_OVER, clearTimeoutListener);
			_sliceShape.addEventListener(MouseEvent.MOUSE_OUT, setTimeoutListener);
			_sliceShape.buttonMode = true;
			_sliceShape.useHandCursor = true;
			showClosedChildren();
		}
		
		public function deactivate():void
		{
			_sliceShape.removeEventListener(MouseEvent.MOUSE_OVER, showOpenChildrenListener);
			//_sliceShape.removeEventListener(MouseEvent.MOUSE_OVER, clearTimeoutListener);
			_sliceShape.removeEventListener(MouseEvent.MOUSE_OUT, setTimeoutListener);
			_sliceShape.buttonMode = false;
			_sliceShape.useHandCursor = false;
			//hideChildren();
		}
		
		public function activateChildren():void
		{
			for each (var childSlice:PieSlice in _slices)
				childSlice.activate();
		}
		
		public function deactivateChildren():void
		{
			for each (var childSlice:PieSlice in _slices)
				childSlice.deactivate();
		}
		
		private function showOpenChildrenListener(evt:MouseEvent):void
		{
			showOpenChildren();
			evt.stopPropagation();
		}
		
		private function showOpenChildren():void
		{
			_opened = true;
			closeNeighbours();
			reorderChildrenAngles(_maxChildrenAutoDegreeSize, 360, PieSlice.SHOW_OPEN_CHILDREN_ANIMATION_TIME + PieSlice.SHOW_OPEN_CHILDREN_DELAY_INTERVAL * _slices.length);
			
			var delayTime:Number = 0;
			for each (var childSlice:PieSlice in _slices)
			{
				TweenLite.to(childSlice, PieSlice.SHOW_OPEN_CHILDREN_ANIMATION_TIME / 1000, { 
					size: _size,
					delay: delayTime,
					overwrite: 0,
					onComplete: function(theSlice:PieSlice):void{
						theSlice.activate();
					},
					onCompleteParams: [childSlice]
				});
				delayTime += PieSlice.SHOW_OPEN_CHILDREN_DELAY_INTERVAL / 1000;
			}
		}
		
		private function hideChildren(animationTime:Number):void
		{
			throw(new Error('Not yet implemented'));
		}
		
		private function showClosedChildren(animationTime:Number = PieSlice.SHOW_CLOSED_CHILDREN_ANIMATION_TIME):void
		{
			_opened = false;
			
			reorderChildrenAngles(_maxChildrenAutoClosedDegreeSize, _degreeSize, animationTime);
			
			deactivateChildren();
			
			var delayTime:Number = 0;
			for each (var childSlice:PieSlice in _slices)
			{
				TweenLite.to(childSlice, animationTime / 1000, { 
					size: PieSlice.CLOSED_CHILDREN_SIZE,
					delay: delayTime,
					overwrite: 0
				});
				delayTime += PieSlice.SHOW_CLOSED_CHILDREN_DELAY_INTERVAL / 1000;
			}
		}
		
		public function setTimeoutListener(evt:MouseEvent):void
		{
			setHideChildrenTimeout(PieSlice.HIDE_CHILDREN_TIMEOUT, PieSlice.HIDE_OPEN_CHILDREN_ANIMATION_TIME);
			evt.stopPropagation();
		}
		
		public function setHideChildrenTimeout(timeoutTime:Number, animationTime:Number):void
		{
			clearHideChildrenTimeout();
			_hideChildrenTimeout = setTimeout(function():void
			{
				showClosedChildren(animationTime);
			}, timeoutTime);
			if(_parentSlice != null)
				_parentSlice.setHideChildrenTimeout(timeoutTime + animationTime, 
					animationTime - PieSlice.HIDE_OPEN_CHILDREN_REDUCTION_INTERVAL);
		}
		
		private function clearTimeoutListener(evt:MouseEvent):void
		{
			clearHideChildrenTimeout();
			evt.stopPropagation();
		}
		
		public function clearHideChildrenTimeout():void
		{
			clearTimeout(_hideChildrenTimeout);
			if (_parentSlice != null)
				_parentSlice.clearHideChildrenTimeout();
		}
		
		public function addSlice(sliceToAdd:PieSlice):PieSlice
		{
			_slices.push(sliceToAdd);
			sliceToAdd.parentSlice = this;
			sliceToAdd.radius = _outerRadius;
			_sliceContainer.addChild(sliceToAdd);
			//reorderChildrenAngles(_maxChildrenAutoDegreeSize, _degreeSize, 0);
			showClosedChildren();
			return sliceToAdd;
		}
		
		public function reorderChildrenAngles(autoDegreeSize:Number, fullSize:Number, animationTime:Number):void
		{
			var allAngles:Number = _slices.length * autoDegreeSize + _childSliceSpacing * _slices.length;
			var childrenAngle:Number = -(allAngles / 2) + autoDegreeSize / 2;
			if (allAngles >= fullSize)
			{
				autoDegreeSize = (fullSize - _childSliceSpacing * _slices.length) / _slices.length;
				allAngles = _slices.length * autoDegreeSize;
				childrenAngle = -(allAngles / 2);
			}
			for each (var childSlice:PieSlice in _slices)
			{
				TweenLite.to(childSlice, animationTime / 1000, { 
					degreeSize: autoDegreeSize, 
					angle: childrenAngle, 
					overwrite: 2} );
				childrenAngle += autoDegreeSize + _childSliceSpacing;
			}
		}
		
		public function drawThis():void
		{
			_sliceShape.graphics.clear();
			_sliceShape.graphics.beginFill(color);
			drawPieSlice(_sliceShape.graphics, 0, 0, -(_degreeSize / 2), (_degreeSize / 2), _innerRadius, _outerRadius);
			_sliceShape.graphics.endFill();
		}
		
		private function drawPieSlice(g:Graphics, centerX:Number, centerY:Number, startAngle:Number, 
			endAngle:Number, innerRadius:Number, outerRadius:Number):void
		{
			drawPieSliceAngle1 = PieSlice.PIBY180 * startAngle;
			drawPieSliceAngle2 = PieSlice.PIBY180 * endAngle;
			
			drawPieSlicePoint1.x = centerX + Math.cos(drawPieSliceAngle1) * innerRadius;
			drawPieSlicePoint1.y = centerY + Math.sin(drawPieSliceAngle1) * innerRadius;
			
			g.moveTo(drawPieSlicePoint1.x, drawPieSlicePoint1.y);
			g.lineTo(centerX + Math.cos(drawPieSliceAngle1) * outerRadius, centerY + Math.sin(drawPieSliceAngle1) * outerRadius);
			
			for (var i:Number = startAngle + 5; i < endAngle; i += 5)
			{
				g.lineTo(centerX + Math.cos(PieSlice.PIBY180 * i) * (outerRadius), centerY + Math.sin(PieSlice.PIBY180 * i) * (outerRadius));
			}
			
			g.lineTo(centerX + Math.cos(drawPieSliceAngle2) * outerRadius, centerY + Math.sin(drawPieSliceAngle2) * outerRadius);
			g.lineTo(centerX + Math.cos(drawPieSliceAngle2) * innerRadius, centerY + Math.sin(drawPieSliceAngle2) * innerRadius);
			
			for (var j:Number = endAngle - 5; j > startAngle; j -= 5)
			{
				g.lineTo(centerX + Math.cos(PieSlice.PIBY180 * j) * (innerRadius), centerY + Math.sin(PieSlice.PIBY180 * j) * (innerRadius));

			}
			
			g.lineTo(drawPieSlicePoint1.x, drawPieSlicePoint1.y);
		}
		
		/**
		 * Getter & Setter
		 */
		
		public function set parentSlice(v:PieSlice):void
		{
			_parentSlice = v;
		}
		
		public function get parentSlice():PieSlice
		{
			return _parentSlice;
		}
		
		public function get slices():Array
		{
			return _slices;
		}
		
		public function set angle(v:Number):void
		{
			_angle = v;
			_sliceShape.rotation = _sliceContainer.rotation = v;
		}
		
		public function get angle():Number
		{
			return _angle;
		}
		
		public function set radius(v:Number):void
		{
			_innerRadius = v;
			_outerRadius = _innerRadius + _size;
			for each(var childSlice:PieSlice in _slices)
				childSlice.radius = _outerRadius;
			drawThis();
		}
		
		public function get radius():Number
		{
			return _innerRadius;
		}
		
		public function set degreeSize(v:Number):void
		{
			_degreeSize = v;
			drawThis();
		}
		
		public function get degreeSize():Number
		{
			return _degreeSize;
		}
		
		public function set size(v:Number):void
		{
			_size = v;
			_outerRadius = _innerRadius + _size;
			for each(var childSlice:PieSlice in _slices)
				childSlice.radius = _outerRadius;
			drawThis();
		}
		
		public function get size():Number
		{
			return _size;
		}
		
		public function get opened():Boolean
		{
			return _opened;
		}
		
	}

}