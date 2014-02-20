package components
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import core.Icomponent;
	import core.LSprite;
	
	import events.LEvent;
	
	import utils.LFilters;
	import utils.LUIManager;
	import utils.LeSpace;
	import utils.UiConst;
	
	use namespace LeSpace;
	/**
	 *@author swellee
	 *2013-4-3
	 *
	 */
	public class LComponent extends LSprite implements Icomponent
	{
		private var _styleName:String;
		private var _contentMask:Rectangle;
		private var bgAsset:DisplayObject;
		private var needRenderBg:Boolean;
		private var _width:int=UiConst.UI_MIN_SIZE;
		private var _height:int=UiConst.UI_MIN_SIZE;
		private var _enable:Boolean=true;
		private var _selected:Boolean;
		private var _canScaleX:Boolean=true;
		private var _canScaleY:Boolean=true;
		private var _data:*;
		public function LComponent()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE,onActive);
		}
		
		/**初次被添加到显示列表时，激活*/
		protected function onActive(event:Event):void
		{
			init();
			addEvents();
			updateStyle();
		}
		
		/**
		 *组件被激活时调用，用于初始化，子类重写 
		 * 
		 */		
		protected function init():void
		{
		}
		/**
		 *构造函数中调用，用于添加交互事件监听 
		 * 
		 */		
		protected function addEvents():void
		{
			addEventListener(Event.REMOVED_FROM_STAGE,onDeactive);
			addGlobalEventListener(LEvent.STYLE_SHEET_CHANGED,onStyleSheetChange);
		}
		/**
		 *销毁时调用，用于移除事件监听 
		 * 
		 */		
		protected function removeEvents():void
		{
			removeEventListener(Event.REMOVED_FROM_STAGE,onDeactive);
			removeGlobalEventListener(LEvent.STYLE_SHEET_CHANGED,onStyleSheetChange);
		}
		/**当被移出显示列表时，停止所有事件侦听*/
		protected function onDeactive(event:Event):void
		{
			removeEvents();
		}
		
		/**样式表变化时，更新样式*/
		private function onStyleSheetChange(evt:LEvent):void
		{
			updateStyle();
		}
		
		public function getDefaultStyleName():String
		{
			return LUIManager.getClassName(this);
		}
		public function get enabled():Boolean
		{
			return _enable;
		}
		
		public function set enabled(value:Boolean):void
		{
			_enable = value;
			LFilters.setEnableFilter(this);
		}
		
		public function get selected():Boolean
		{
			return _selected;
		}
		public function set selected(value:Boolean):void
		{
			_selected=value;
		}
		public function setXY(x:int, y:int):void
		{
			this.x=x;
			this.y=y;
		}
		
		public function setWH(width:int=-1,height:int=-1):void
		{
			if(width!=-1)
				this.width=width;
			if(height!=-1)
				this.height=height;
		}
		
		public function dispatchGlobalEvent(event:Event):void
		{
			LUIManager.styleObserver.dispatchEvent(event);
		}
		
		public function addGlobalEventListener(eventType:String, listenFun:Function):void
		{
			LUIManager.styleObserver.addEventListener(eventType,listenFun);
		}
		
		public function removeGlobalEventListener(eventType:String, listenFun:Function):void
		{
			LUIManager.styleObserver.removeEventListener(eventType,listenFun);
		}
		
		public function get style():String
		{
			return _styleName||=getDefaultStyleName();
		}
		
		public function set style(value:String):void
		{
			if(_styleName!=value)
			{
				_styleName=value;
				updateStyle();
			}
		}
		private function onRenderHandler(evt:LEvent):void
		{
			if(!stage)return;
			render();
		}
		
		/**舞台重绘处理函数，可在此函数中执行样式变更*/
		protected function render():void
		{
			renderBg();
		}
		/**更新样式*/
		private function updateStyle():void
		{
			if(!stage)return;
			LUIManager.updateStyle(this);
		}
		public function resetStyle():void
		{
			style=getDefaultStyleName();
		}
		
		public function get bounds():Rectangle
		{
			return new Rectangle(x,y,width,height);
		}
		
		public function get canScaleX():Boolean
		{
			return _canScaleX;
		}
		
		public function set canScaleX(value:Boolean):void
		{
			_canScaleX=value;
		}
		
		public function get canScaleY():Boolean
		{
			return _canScaleY;
		}
		
		public function set canScaleY(value:Boolean):void
		{
			_canScaleY=value;
		}
		
		public function setBg(asset:DisplayObject):void
		{
			if(!bgAsset)// 首次调用此方法
			{
				addChildAt(asset,0);
				asset.width=_width;
				asset.height=_height;
				resizeMask();
			}
			else
			{
				needRenderBg=true;
				render();
			}
			bgAsset=asset;
		}
		/**重置背景图尺寸*/
		private function resizeBgAsset():void
		{
			if(bgAsset)
			{
				removeChildAt(0);
				addChildAt(bgAsset,0);
				bgAsset.width=_width;
				bgAsset.height=_height;
			}
		}

		/**重绘时检测更新背景*/
		private function renderBg():void
		{
			if(needRenderBg)
			{
				needRenderBg=false;
				resizeBgAsset();
				resizeMask();
			}
		}
		/**
		 * 组件遮罩矩形
		 * 
		 */		
		protected function get contentMask():Rectangle
		{
			if(!_contentMask)
			{
				_contentMask=new Rectangle(0,0,width,height);
				this.scrollRect=_contentMask;
			}
			return _contentMask;
		}
		
		//重写宽高getter setter
		override public function get width():Number
		{
			return _width;
		}
		override public function get height():Number
		{
			return _height;
		}
		
		override public function set width(value:Number):void
		{
			if(value==_width)return;
			
			_width=value;
			needRenderBg=true;
			render();
		}
		override public function set height(value:Number):void
		{
			if(value==_height)return;
			
			_height=value;
			needRenderBg=true;
			render();
		}
		/**重置遮罩尺寸*/
		private function resizeMask():void
		{
			contentMask.width=width;
			contentMask.height=height;
			this.scrollRect=contentMask;
		}
		/**递归移除所有子级显示对象*/
		private function removeAllChild(comp:DisplayObjectContainer):void
		{
			var childCnt:int=comp.numChildren;
			while(--childCnt>-1)
			{
				var obj:DisplayObject=comp.removeChildAt(childCnt);
				if(obj is DisplayObjectContainer)
				{
					removeAllChild(obj as DisplayObjectContainer);
				}
			}
		}
		public function get data():*
		{
			return _data;
		}
		public function set data(val:*):void
		{
			_data=val;
		}
		
		public function dispose():void
		{
			removeEvents();
			removeEventListener(Event.ADDED_TO_STAGE,onActive);
			removeAllChild(this);
			_data=null;
			_contentMask=null;
		}
	}
}